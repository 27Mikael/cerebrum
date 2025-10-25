from fastapi import APIRouter

router = APIRouter(prefix="/data", tags=["Data API"])

@router.get("/chunks")
def retriever():
    # for file in user interests
    # generate topics according to interests
    # match user topics to data
    # generate chunks
    pass

