
# Cerebrum 

Cerebrum is a **local, AI-powered learning assistant** designed to help users learn efficiently and retain knowledge effectively. It leverages Rose 🌹, a custom LLM, to guide learning, track progress, and optimize study strategies.

## Features

### Priority Features

* [ ] **RAG (Retrieval-Augmented Generation)** – Ensures responses are contextually relevant and accurate by retrieving information from user notes and resources.
* [ ] **MCP (Model Context Protocol)** – Maintains a record of user progress and user-generated notes, enabling contextual continuity across sessions.
* [ ] **Adaptive Learning Tools** –

  * Spaced repetition and active recall flashcards
  * Auto-generated quizzes and examinations tailored to user understanding
* [ ] **Rich Media Support** – Flashcards and notes can include text, images, audio, video, and LaTeX formatting.
* [ ] **Organized Study Management** – Nested decks, tags, and filtered views allow targeted study sessions and content organization.
* [ ] **Progress Tracking & Feedback** – Detailed statistics including retention graphs, review patterns, and time spent, combined with adaptive learning based on difficulty metrics and user feedback.
* [ ] **Offline-First Architecture** – Fully functional without internet connectivity; runs entirely on a local machine.
* [ ] **Integration with External Platforms** – Supports importing Anki decks and other quiz formats for seamless study continuity.

### Nice-to-Have Features

* [ ] **Flexible Card Templates** – Customize card layouts to suit different types of content.
* [ ] **Portability & Sync (Future)** – Mobile usage possible, though hosting and synchronization are user-managed.
* [ ] **Add-Ons & Extensions (Future)** – Planned support for additional plugins and learning tools.

## Installation

**Requirements:**

* Python 3.11+
* Pip package manager
* Local machine (Windows/Linux/macOS)

**Steps:**

1. Clone the repository:

```bash
git clone https://github.com/yourusername/cerebrum.git
cd cerebrum
```

2. Create and activate a virtual environment:

```bash
python -m venv venv
source venv/bin/activate   # Linux/macOS
venv\Scripts\activate      # Windows
```

3. Install dependencies:

```bash
pip install -r requirements.txt
```

4. Start Cerebrum:

```bash
python main.py
```

## Usage

* Run `main.py` to launch the interface and interact with Rose 🌹.
* Add PDFs, notes, or decks to your local directories to enable RAG-powered queries.
* Study using flashcards, auto-generated quizzes, or custom exams.
* Track your progress and adapt learning strategies based on statistics.

### Example Commands

```python
# Load a topic
topic = Topic("Physics", pdf_dir="data/pdfs", notes_dir="data/notes", db_dir="data/db", embedding_model="openai")

# Generate flashcards
topic.generate_flashcards()

# Start a quiz session
topic.start_quiz()
```

## Folder Structure

```
cerebrum/
├── data/
│   ├── pdfs/       # User PDFs
│   ├── notes/      # User-generated notes
│   └── db/         # Local database for embeddings and progress
├── cerebrum_core/
│   ├── embed_inator.py
│   ├── learning_tools.py
│   └── llm_interface.py
├── main.py          # Entry point for the app
├── requirements.txt # Python dependencies
└── README.md
```

## Contributing

* Contributions are welcome! Please open issues or pull requests.
* Ensure any new feature is compatible with offline-first usage.
* Add tests and update documentation for new modules.

## License

Cerebrum is released under a **custom research-oriented license** (see LICENSE.md) that allows research and educational use but restricts commercial use and redistribution without permission.
