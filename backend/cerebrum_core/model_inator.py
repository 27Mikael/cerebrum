from pydantic import BaseModel
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

class Subquery(BaseModel):
    text: str
    domain: str
    subject: str

class TranslatedQuery(BaseModel):
    rewritten: str
    domain: str | List[str]
    subject: str | List[str]
    subqueries: List[Subquery]

class FileMetadata(BaseModel):
    title: str
    domain: str
    subject: str
    authors: str | List[str]
    keywords: str | List[str]

class Chunk(BaseModel):
     pass
