from django.conf import settings
from django.core.mail import send_mail

from pyoneers_platform.course.models import ChapterFeedback


def send_feedback_email(instance: ChapterFeedback):
    """Sends an email to the admin when a new feedback is submitted."""
    subject = f"New Feedback from {instance.user.username if instance.user else 'Anonymous'}"
    message = f"""
        A new feedback has been submitted for the chapter: {instance.chapter.title}

        Simplicity Rating: {instance.simplicity_rating}
        Practicality Rating: {instance.practicality_rating}
        Engagement Rating: {instance.engagement_rating}
        Overall Rating: {instance.overall_rating}

        Feedback:
        {instance.feedback}

        This is an automated message.
        """
    recipient_list = [
        settings.DJANGO_SUPERUSER_EMAIL,
    ]
    send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, recipient_list)
