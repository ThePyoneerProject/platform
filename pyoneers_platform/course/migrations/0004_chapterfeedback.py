# Generated by Django 4.2.5 on 2023-11-12 15:29

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):
    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ("course", "0003_alter_section_unique_together"),
    ]

    operations = [
        migrations.CreateModel(
            name="ChapterFeedback",
            fields=[
                ("id", models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name="ID")),
                ("simplicity_rating", models.IntegerField()),
                ("practicality_rating", models.IntegerField()),
                ("engagement_rating", models.IntegerField()),
                ("feedback", models.TextField()),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("commit_hash", models.CharField(max_length=255)),
                (
                    "chapter",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE, related_name="feedback", to="course.chapter"
                    ),
                ),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="chapter_feedback",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]
