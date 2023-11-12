from django.contrib import admin

from .models import Chapter, Section, ChapterFeedback

admin.site.register(Chapter)
admin.site.register(Section)
admin.site.register(ChapterFeedback)
