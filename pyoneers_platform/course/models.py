"""
Defines Chapter and Section models for a Django app. These models are auto-populated by a GitHub repository
via webhooks.

Models:
    - Chapter: Represents a chapter in a course.
    - Section: Represents a section in a chapter.
"""
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator, MaxValueValidator
from django.db import models
from django.urls import reverse


class OrderNavigationMixin(models.Model):
    """
    Mixin that adds next and previous properties to a model which has an 'order' field.
    Assumes that the model has a 'get_queryset' class method which returns the relevant QuerySet.
    """

    order = models.IntegerField()

    class Meta:
        abstract = True  # Indicates that this model should not be used to create any database table

    def get_ordered_queryset(self):
        """
        This should be implemented in the subclass if the default 'objects.all()'
        does not apply. For example, if order is scoped to a related object, override
        this method to return the correct scoped queryset.
        """
        return self.__class__.objects.all()

    @property
    def previous(self):
        """Returns the previous item or None."""
        return self.get_ordered_queryset().filter(order__lt=self.order).order_by("-order").first()

    @property
    def next(self):
        """Returns the next item or None."""
        return self.get_ordered_queryset().filter(order__gt=self.order).order_by("order").first()

    @property
    def has_previous(self):
        """Returns True if the previous item exists."""
        return self.previous is not None

    @property
    def has_next(self):
        """Returns True if the next item exists."""
        return self.next is not None

    @property
    def is_first(self):
        """Return True if this is the first item."""
        return self.order == self.get_ordered_queryset().order_by("order").first().order

    @property
    def is_last(self):
        """Return True if this is the last item."""
        return self.order == self.get_ordered_queryset().order_by("-order").first().order


class Chapter(OrderNavigationMixin, models.Model):
    """Represents a course chapter. Auto-populated via GitHub webhook."""

    slug = models.CharField(max_length=255)
    title = models.CharField(max_length=255)

    def __str__(self):
        return self.title

    def get_absolute_url(self):
        return reverse("course:chapter", args=[str(self.slug)])

    @property
    def url(self):
        return self.get_absolute_url()

    class Meta:
        ordering = ["order"]


class Section(OrderNavigationMixin, models.Model):
    """Represents a section within a Chapter. Auto-populated via GitHub webhook."""

    chapter = models.ForeignKey(Chapter, related_name="sections", on_delete=models.CASCADE)

    slug = models.CharField(max_length=255)
    title = models.CharField(max_length=255)
    content = models.TextField()

    def __str__(self):
        return self.title

    @property
    def url(self):
        return self.get_absolute_url()

    def get_ordered_queryset(self):
        """
        Override to return a QuerySet of sections within the same chapter.
        """
        return super().get_ordered_queryset().filter(chapter=self.chapter)

    def get_absolute_url(self):
        return reverse("course:section", args=[str(self.chapter.slug), str(self.slug)])

    class Meta:
        ordering = ["order"]
        unique_together = ["chapter", "order"]


class ChapterFeedback(models.Model):
    """Represents feedback for a chapter."""

    chapter = models.ForeignKey(Chapter, related_name="feedback", on_delete=models.CASCADE, verbose_name="Chapter")
    user = models.ForeignKey(
        User, related_name="chapter_feedback", on_delete=models.CASCADE, verbose_name="User", blank=True, null=True
    )
    is_anonymous = models.BooleanField(verbose_name="Anonymous", default=False, blank=True)

    simplicity_rating = models.IntegerField(
        verbose_name="Simplicity", validators=[MinValueValidator(1), MaxValueValidator(10)]
    )
    practicality_rating = models.IntegerField(
        verbose_name="Practicality", validators=[MinValueValidator(1), MaxValueValidator(10)]
    )
    engagement_rating = models.IntegerField(
        verbose_name="Engagement", validators=[MinValueValidator(1), MaxValueValidator(10)]
    )
    feedback = models.TextField(verbose_name="Feedback", blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    @property
    def overall_rating(self):
        """Returns the average of the simplicity, practicality, and engagement ratings. Uses 2 decimal places."""
        return round((self.simplicity_rating + self.practicality_rating + self.engagement_rating) / 3, 2)
