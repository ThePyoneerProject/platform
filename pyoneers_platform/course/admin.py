from django.contrib import admin

from .models import Chapter, Section, ChapterFeedback

admin.site.register(Chapter)
admin.site.register(Section)


@admin.register(ChapterFeedback)
class ChapterFeedbackAdmin(admin.ModelAdmin):
    list_display = (
        "chapter",
        "user",
        "simplicity_rating",
        "practicality_rating",
        "engagement_rating",
        "feedback",
    )
