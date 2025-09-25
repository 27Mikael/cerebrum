from pydantic import BaseModel
from typing import Optional, List


# the following is a context provider:
# use PyMuPDFLoader to split the text
# this function will ingest md and pdf notes
# itll the return the chunked data and pass it on to embed_inator
# Hierarchy: subject -> topic -> subtopic

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
    topics: List[Topic] = []
    description: str
    
    def add_topic(self, topic_name: str, description: str):
        topic = Topic(name=topic_name, description=description)
        self.topics.append(topic)
        return topic

class Domain(BaseModel):
    name: str
    subjects: List[Subject] = []
    description: str

    def add_subject(self, subject_name: str, description: str):
        subject = Subject(name=subject_name, description=description)
        self.subjects.append(subject)
        return subject

class KnowledgeBase(BaseModel):
    name: str
    domains: List[Domain] = []
    description: str

    def add_domain(self, domain_name: str, description: str):
        domain = Domain(name=domain_name, description=description) 
        self.domains.append(domain)
        return domain
