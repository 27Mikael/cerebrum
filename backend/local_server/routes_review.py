from fastapi import APIRouter

router = APIRouter(prefix="/bubble", tags=["Study Bubble API"])
"""
    Study bubbles handle the
         assesment marking,
         notes review,
"""

# %%
# TODO: find a way to implement memory{quiz grades, exam grades and track progress}
#
# take in user notes(input)
#   markdown files that are then split according to headers
#   or direct to text chunking if no header heirachy
#
#       should be able to assess user notes, {interests} and {goals}:
#       guide user learning to achieve goals {path user goals step by step}
#       match users learning pace as stated in {goals}
#
#       give feedback {hints} on user notes and any inaccurate/incomplete notes
#           should nudge user to the relevant resources covering the topic
#           create quizzes and examinations from user notes {grade them too}
#
#           generate quizzes in an active recall fashion
#              tailor to per domain {structure and approach}
#%%
@router.get("/assesment")
def _():
    # for file in user interests
    # generate topics according to interests
    # match user topics to data
    # generate chunks
    pass

@router.post("/review")
def _():
    """
        Study bubbles handle the
             assesment marking,
             notes review,
    """
    # for file in user interests
    # generate topics according to interests
    # match user topics to data
    # generate chunks
    pass

