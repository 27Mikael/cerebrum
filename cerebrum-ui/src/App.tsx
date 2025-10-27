import { useState, useEffect } from "react";

interface Message {
  role: "user" | "bot";
  content: string;
  status?: "sent" | "failed" | "pending";
}

interface FileRegistry {
  hash_id: string;
  original_name: string;
  sanitized_name: string;
  converted: boolean;
  embedded: boolean;
}

interface Note {
  filename: string;
  title: string;
  content: string;
}

type ViewMode = "chat" | "notes";
type NotesView = "list" | "editor";

const API_BASE = "http://localhost:8000";

export default function App() {
  const [viewMode, setViewMode] = useState<ViewMode>("chat");
  const [notesView, setNotesView] = useState<NotesView>("list");
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [notes, setNotes] = useState<Note[]>([]);
  const [selectedNote, setSelectedNote] = useState<Note | null>(null);
  const [fileRegistry, setFileRegistry] = useState<FileRegistry[]>([]);
  const [isLoadingNotes, setIsLoadingNotes] = useState(false);

  // Fetch notes from backend
  const fetchNotes = async () => {
    setIsLoadingNotes(true);
    try {
      const response = await fetch(`${API_BASE}/notes/`);
      if (response.ok) {
        const data = await response.json();
        setNotes(data);
      }
    } catch (err) {
      console.error("Failed to fetch notes:", err);
    } finally {
      setIsLoadingNotes(false);
    }
  };

  // Fetch file registry
  const fetchRegistry = async () => {
    try {
      const response = await fetch(`${API_BASE}/process/`);
      const data = await response.json();
      setFileRegistry(data.registry || []);
    } catch (err) {
      console.error("Failed to fetch registry:", err);
    }
  };

  // Fetch data on mount and when switching to notes view
  useEffect(() => {
    fetchRegistry();
  }, []);

  useEffect(() => {
    if (viewMode === "notes") {
      fetchNotes();
    }
  }, [viewMode]);

  // Send message function with retry support
  const sendMessage = async (messageContent?: string) => {
    const text = messageContent ?? input;
    if (!text.trim()) return;

    const newMessage: Message = { role: "user", content: text, status: "pending" };
    setMessages((prev) => [...prev, newMessage]);
    if (!messageContent) setInput("");

    try {
      const response = await fetch(`${API_BASE}/chat/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ text }),
      });

      if (!response.ok) throw new Error("Server error");

      const data = await response.json();
      const reply: Message = {
        role: "bot",
        content: data.reply,
        status: "sent" as Message["status"],
      };

      setMessages((prev) =>
        prev
          .map((msg) =>
            msg === newMessage ? { ...msg, status: "sent" as Message["status"] } : msg
          )
          .concat(reply)
      );
    } catch (err) {
      console.error(err);
      setMessages((prev) =>
        prev.map((msg) =>
          msg === newMessage ? { ...msg, status: "failed" as Message["status"] } : msg
        )
      );
    }
  };

  const clearChat = () => {
    setMessages([]);
  };

  const createNewNote = async () => {
    const newNote = {
      title: "Untitled Note",
      content: "# Untitled Note\n\n",
    };

    try {
      const response = await fetch(`${API_BASE}/notes/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(newNote),
      });

      if (response.ok) {
        const savedNote = await response.json();
        setNotes((prev) => [savedNote, ...prev]);
        setSelectedNote(savedNote);
        setNotesView("editor");
      } else {
        alert("Failed to create note");
      }
    } catch (err) {
      console.error("Failed to create note:", err);
      alert("Failed to create note");
    }
  };

  const selectNote = (note: Note) => {
    setSelectedNote(note);
    setNotesView("editor");
  };

  const updateSelectedNote = async (field: "title" | "content", value: string) => {
    if (!selectedNote) return;

    const updatedNote = { ...selectedNote, [field]: value };
    setSelectedNote(updatedNote);

    // Optimistic update
    setNotes((prev) =>
      prev.map((n) => (n.filename === selectedNote.filename ? updatedNote : n))
    );

    // Save to backend
    try {
      await fetch(`${API_BASE}/notes/${selectedNote.filename}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: updatedNote.title,
          content: updatedNote.content,
        }),
      });
    } catch (err) {
      console.error("Failed to update note:", err);
    }
  };

  const deleteNote = async (filename: string) => {
    if (!confirm("Are you sure you want to delete this note?")) return;

    try {
      const response = await fetch(`${API_BASE}/notes/${filename}`, {
        method: "DELETE",
      });

      if (response.ok) {
        setNotes((prev) => prev.filter((n) => n.filename !== filename));
        if (selectedNote?.filename === filename) {
          setSelectedNote(null);
          setNotesView("list");
        }
      } else {
        alert("Failed to delete note");
      }
    } catch (err) {
      console.error("Failed to delete note:", err);
      alert("Failed to delete note");
    }
  };

  const handleFileUpload = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;

    if (!file.name.endsWith(".pdf")) {
      alert("Only PDF files are allowed");
      return;
    }

    const formData = new FormData();
    formData.append("file", file);

    try {
      const response = await fetch(`${API_BASE}/process/upload`, {
        method: "POST",
        body: formData,
      });
      const data = await response.json();
      alert(`✅ ${data.message}`);
    } catch (err) {
      console.error(err);
      alert("Failed to upload PDF");
    }

    event.target.value = "";
    fetchRegistry();
  };

  return (
    <div className="h-screen w-screen flex bg-slate-950 text-gray-100">
      {/* ===== LEFT SIDEBAR ===== */}
      <aside className="w-1/5 bg-slate-900 p-6 border-r-2 border-slate-700 flex flex-col">
        <h2 className="text-2xl font-bold mb-6 text-emerald-400">⚙️ Options</h2>
        <ul className="space-y-3 flex-1">
          <li
            onClick={() => setViewMode("chat")}
            className={`p-3 rounded-lg cursor-pointer transition border ${viewMode === "chat"
                ? "bg-emerald-600 border-emerald-500"
                : "bg-slate-800 hover:bg-slate-700 border-slate-700"
              }`}
          >
            <span className="text-lg">💬 Chat</span>
          </li>
          <li
            onClick={() => {
              setViewMode("notes");
              setNotesView("list");
            }}
            className={`p-3 rounded-lg cursor-pointer transition border ${viewMode === "notes"
                ? "bg-emerald-600 border-emerald-500"
                : "bg-slate-800 hover:bg-slate-700 border-slate-700"
              }`}
          >
            <span className="text-lg">📝 Notes</span>
          </li>
        </ul>

        {/* Upload Section */}
        <div className="mt-auto pt-6 border-t-2 border-slate-700">
          <label className="block w-full bg-emerald-600 hover:bg-emerald-500 p-3 rounded-lg font-semibold transition border-2 border-emerald-500 cursor-pointer text-center">
            📄 Upload PDF
            <input
              type="file"
              accept=".pdf"
              onChange={handleFileUpload}
              className="hidden"
            />
          </label>
        </div>
      </aside>

      {/* ===== CENTER AREA ===== */}
      <main className="flex-1 flex flex-col bg-slate-900">
        {/* Header */}
        <header className="bg-slate-800 border-b-2 border-slate-700 p-4 flex items-center justify-between">
          <h1 className="text-2xl font-bold text-emerald-400">
            {viewMode === "chat" ? "💭 Cerebrum Chat" : "📝 My Notes"}
          </h1>
          {viewMode === "notes" && notesView === "editor" && (
            <button
              onClick={() => setNotesView("list")}
              className="bg-slate-700 hover:bg-slate-600 px-4 py-2 rounded-lg font-semibold transition border border-slate-600"
            >
              ← Back to Notes
            </button>
          )}
        </header>

        {/* CHAT VIEW */}
        {viewMode === "chat" && (
          <>
            {/* Messages */}
            <div className="flex-1 overflow-y-auto p-6 space-y-4">
              {messages.length === 0 ? (
                <div className="h-full flex items-center justify-center">
                  <p className="text-gray-400 text-lg">Start a conversation with Cerebrum...</p>
                </div>
              ) : (
                messages.map((msg, i) => (
                  <div
                    key={i}
                    className={`p-4 rounded-xl max-w-2xl shadow-lg border-2 ${msg.role === "user"
                        ? "bg-indigo-600 border-indigo-500 ml-auto text-white"
                        : "bg-slate-800 border-slate-600 text-gray-100"
                      }`}
                  >
                    <div className="text-xs font-semibold mb-1 opacity-70">
                      {msg.role === "user" ? "You" : "🤖 Cerebrum"}
                    </div>
                    <div className="text-base leading-relaxed">{msg.content}</div>
                    {msg.role === "user" && msg.status === "pending" && (
                      <span className="mt-2 text-xs opacity-70">Sending...</span>
                    )}
                    {msg.role === "user" && msg.status === "failed" && (
                      <button
                        onClick={() => sendMessage(msg.content)}
                        className="mt-2 bg-yellow-500 hover:bg-yellow-400 px-2 py-1 rounded text-xs font-semibold"
                      >
                        Retry
                      </button>
                    )}
                  </div>
                ))
              )}
            </div>

            {/* Input Area */}
            <div className="bg-slate-800 border-t-2 border-slate-700 p-4">
              <div className="flex gap-3 max-w-4xl mx-auto">
                <input
                  className="flex-1 bg-slate-900 border-2 border-slate-600 p-4 rounded-lg outline-none focus:border-emerald-500 transition text-lg"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === "Enter" && sendMessage()}
                  placeholder="Ask Cerebrum anything..."
                />
                <button
                  onClick={() => sendMessage()}
                  className="bg-emerald-600 hover:bg-emerald-500 px-8 py-4 rounded-lg font-semibold text-lg transition shadow-lg border-2 border-emerald-500"
                >
                  Send
                </button>
              </div>
            </div>
          </>
        )}

        {/* NOTES LIST VIEW */}
        {viewMode === "notes" && notesView === "list" && (
          <div className="flex-1 overflow-y-auto p-6">
            {isLoadingNotes ? (
              <div className="h-full flex items-center justify-center">
                <p className="text-gray-400 text-lg">Loading notes...</p>
              </div>
            ) : (
              <div className="grid grid-cols-3 gap-6 max-w-6xl">
                {/* Create New Note Card */}
                <div
                  onClick={createNewNote}
                  className="bg-slate-800 border-2 border-slate-700 rounded-lg p-8 flex flex-col items-center justify-center cursor-pointer hover:bg-slate-750 hover:border-slate-600 transition min-h-64"
                >
                  <div className="text-6xl mb-4 text-slate-600">+</div>
                  <div className="text-lg text-slate-400 font-semibold">Create new note</div>
                </div>

                {/* Existing Notes */}
                {notes.map((note) => (
                  <div
                    key={note.filename}
                    className="bg-slate-800 border-2 border-slate-700 rounded-lg p-6 cursor-pointer hover:bg-slate-750 hover:border-slate-600 transition min-h-64 flex flex-col relative group"
                    onClick={() => selectNote(note)}
                  >
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        deleteNote(note.filename);
                      }}
                      className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition text-red-500 hover:text-red-400"
                    >
                      ⋮
                    </button>

                    <div className="text-3xl mb-4">📒</div>
                    <h3 className="text-lg font-semibold text-gray-200 mb-2 truncate">
                      {note.title}
                    </h3>
                    <p className="text-sm text-gray-400 mb-4 line-clamp-3">
                      {note.content || "No content"}
                    </p>
                    <div className="text-xs text-gray-500 mt-auto">
                      {note.filename}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* NOTES EDITOR VIEW */}
        {viewMode === "notes" && notesView === "editor" && selectedNote && (
          <div className="flex-1 flex flex-col p-6 space-y-4">
            <input
              className="bg-slate-800 border-2 border-slate-600 p-4 rounded-lg outline-none focus:border-emerald-500 transition text-2xl font-semibold"
              value={selectedNote.title}
              onChange={(e) => updateSelectedNote("title", e.target.value)}
              placeholder="Note title..."
            />
            <textarea
              className="flex-1 bg-slate-800 border-2 border-slate-600 p-4 rounded-lg outline-none focus:border-emerald-500 transition text-lg resize-none"
              value={selectedNote.content}
              onChange={(e) => updateSelectedNote("content", e.target.value)}
              placeholder="Start writing..."
            />
            <div className="text-sm text-gray-400">
              {selectedNote.content.length} characters · {selectedNote.filename}
            </div>
          </div>
        )}
      </main>

      {/* ===== RIGHT SIDEBAR ===== */}
      <aside className="w-1/5 bg-slate-900 p-6 border-l-2 border-slate-700 flex flex-col">
        <h2 className="text-2xl font-bold mb-4 text-emerald-400">📁 Files</h2>

        {/* File Registry List */}
        <div className="flex-1 overflow-y-auto space-y-2 mb-4">
          <button
            onClick={fetchRegistry}
            className="mb-2 bg-emerald-600 hover:bg-emerald-500 px-2 py-1 rounded text-sm font-semibold w-full"
          >
            Refresh Files
          </button>
          {fileRegistry.length === 0 ? (
            <div className="bg-slate-800 p-3 rounded-lg border border-slate-700 text-center">
              <p className="text-sm text-gray-400">No files yet</p>
            </div>
          ) : (
            fileRegistry.map((file) => (
              <div
                key={file.hash_id}
                className="bg-slate-800 p-3 rounded-lg border border-slate-700"
              >
                <div className="text-xs font-semibold text-gray-300 truncate mb-1">
                  {file.sanitized_name || file.original_name}
                </div>
                <div className="flex gap-2 text-xs">
                  <span
                    className={`px-2 py-1 rounded ${file.converted ? "bg-green-600 text-white" : "bg-yellow-600 text-white"
                      }`}
                  >
                    {file.converted ? "✓ Conv" : "⏳ Conv"}
                  </span>
                  <span
                    className={`px-2 py-1 rounded ${file.embedded ? "bg-green-600 text-white" : "bg-yellow-600 text-white"
                      }`}
                  >
                    {file.embedded ? "✓ Embd" : "⏳ Embd"}
                  </span>
                </div>
              </div>
            ))
          )}
        </div>

        {viewMode === "chat" && (
          <button
            onClick={clearChat}
            className="w-full bg-red-600 hover:bg-red-500 p-3 rounded-lg font-semibold transition border-2 border-red-500"
          >
            🗑️ Clear Chat
          </button>
        )}

        {viewMode === "notes" && (
          <button
            onClick={fetchNotes}
            className="w-full bg-emerald-600 hover:bg-emerald-500 p-3 rounded-lg font-semibold transition border-2 border-emerald-500"
          >
            🔄 Refresh Notes
          </button>
        )}
      </aside>
    </div>
  );
}
