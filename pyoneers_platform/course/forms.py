from django import forms

from pyoneers_platform.course.models import ChapterFeedback


class ChapterFeedbackForm(forms.ModelForm):
    practicality_rating = forms.IntegerField(error_messages={"required": "Please select a practicality rating"})
    simplicity_rating = forms.IntegerField(error_messages={"required": "Please select a simplicity rating"})
    engagement_rating = forms.IntegerField(error_messages={"required": "Please select an engagement rating"})

    class Meta:
        model = ChapterFeedback
        fields = [
            "practicality_rating",
            "simplicity_rating",
            "engagement_rating",
            "feedback",
            "is_anonymous",
        ]

    def save(self, commit=True):
        """Set the user field to the initial value and the chapter field to the initial value."""
        self.instance.chapter = self.initial.get("chapter")
        if not self.instance.is_anonymous:
            self.instance.user = self.initial.get("user")
        return super().save(commit=commit)
