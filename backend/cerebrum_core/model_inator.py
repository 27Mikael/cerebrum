from datetime import datetime
from pydantic import BaseModel, Field
from typing import Optional, List 

class Subtopic(BaseModel):
    name: str
    description: str

class Topic(BaseModel):
    name: str
    subtopics: List[Subtopic] = []
    description: Optional[str] = None

    def add_subtopic(self, subtopic_name: str, description: str):
        subtopic = Subtopic(name=subtopic_name, description=description)
        self.subtopics.append(subtopic)
        return subtopic

class Subject(BaseModel):
    name: str
    description: str
    topics: List[Topic] = []
    
    def add_topic(self, topic_name: str, description: str):
        topic = Topic(name=topic_name, description=description)
        self.topics.append(topic)
        return topic

class Domain(BaseModel):
    name: str
    description: str
    subjects: List[Subject] = []

    def add_subject(self, subject_name: str, description: str):
        subject = Subject(name=subject_name, description=description)
        self.subjects.append(subject)
        return subject

class KnowledgeBase(BaseModel):
    name: str
    description: str
    domains: List[Domain] = []

    def add_domain(self, domain_name: str, description: str):
        domain = Domain(name=domain_name, description=description) 
        self.domains.append(domain)
        return domain

#############################################################################
#
#                               QUERY MODELS FOR LLM INTERACTIONS
#
############################################################################


class Subquery(BaseModel):
    text: str
    domain: Optional[str] = None
    subject: Optional[str] = None

class TranslatedQuery(BaseModel):
    rewritten: str
    domain: Optional[str | List[str]] = None
    subject: Optional[str | List[str]] = None
    subqueries: List[Subquery]

class FileMetadata(BaseModel):
    title: str
    domain: str
    subject: str
    authors: str | List[str]
    keywords: str | List[str]

class Chunk(BaseModel):
     pass


#############################################################################
#
#                               MODELS FOR NOTES AND CONTENT SHARING
#
############################################################################

class NoteBase(BaseModel):
    title: str
    content: str

class NoteOut(NoteBase):
    filename: str



#############################################################################
#
#                               MODELS FOR INTERACTIVE USER LEARNING
#
#############################################################################

class Quiz(BaseModel):
    question: str
    answer: str
    options: List[str] = []

class Review(BaseModel):
    misconception: str

class CreateStudyBubble(BaseModel):
    name: str
    description: str = ""
    domains: List[str] = Field(default_factory=list)
    user_goals: List[str] = Field(default_factory=list)

class StudyBubble(CreateStudyBubble):
    id: str
    created_at: datetime

class CreateResearchProject(BaseModel):
    name: str
    description: str = ""
    domains: List[str] = Field(default_factory=list)
    user_goals: List[str] = Field(default_factory=list)

class ResearchProject(CreateResearchProject):
    id: str
    created_at: datetime




