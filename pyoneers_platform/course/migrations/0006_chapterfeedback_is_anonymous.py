# Generated by Django 4.2.5 on 2023-11-12 19:32

from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("course", "0005_alter_chapterfeedback_chapter_and_more"),
    ]

    operations = [
        migrations.AddField(
            model_name="chapterfeedback",
            name="is_anonymous",
            field=models.BooleanField(blank=True, default=False, verbose_name="Anonymous"),
        ),
    ]
