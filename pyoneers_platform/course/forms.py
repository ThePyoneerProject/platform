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

    def __init__(self, *args, **kwargs):
        self.user = kwargs.pop("user", None)
        self.chapter = kwargs.pop("chapter", None)
        super().__init__(*args, **kwargs)
        self.fields["simplicity_rating"].error_messages = {"invalid": "Please select a simplicity rating."}
        self.fields["practicality_rating"].error_messages = {"invalid": "Please select a practicality rating."}
        self.fields["engagement_rating"].error_messages = {"invalid": "Please select an engagement rating."}

    def save(self, commit=True):
        feedback = super().save(commit=False)
        feedback.chapter = self.chapter

        if not self.cleaned_data.get("is_anonymous", False):
            feedback.user = self.user
        else:
            feedback.user = None

        if commit:
            feedback.save()
        return feedback
