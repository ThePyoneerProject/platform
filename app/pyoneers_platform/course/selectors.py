from django.contrib.auth.models import User, AnonymousUser

from pyoneers_platform.course.models import Chapter, ChapterFeedback


def has_provided_feedback(user: User or AnonymousUser, chapter: Chapter) -> bool:
    """Returns True if the user has provided feedback for the chapter."""
    if isinstance(user, AnonymousUser):
        return False
    return ChapterFeedback.objects.filter(user=user, chapter=chapter).exists()
