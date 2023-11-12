from django.http import HttpResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.views.generic import DetailView

from pyoneers_platform.course.forms import ChapterFeedbackForm
from pyoneers_platform.course.models import Chapter, Section
from pyoneers_platform.course.services import send_feedback_email


class SectionDetailView(DetailView):
    model = Section
    context_object_name = "section"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["all_chapters"] = Chapter.objects.all().order_by("order")
        return context

    def get_object(self, queryset=None):
        return get_object_or_404(Section, slug=self.kwargs["section_slug"], chapter__slug=self.kwargs["chapter_slug"])


section_view = SectionDetailView.as_view()


def redirect_to_first_section(request, chapter_slug):
    chapter = get_object_or_404(Chapter, slug=chapter_slug)
    first_section = chapter.sections.first()
    return redirect(first_section)


def chapter_feedback_view(request, chapter_slug: str) -> HttpResponse:
    """
    Handles the feedback form display and submission for a chapter.
    Redirects if not an HTMX request.
    Processes the form submission if POST request is made.
    """
    chapter = get_object_or_404(Chapter, slug=chapter_slug)
    context = {
        "chapter": chapter,
    }
    if not request.htmx:
        return redirect("course:chapter", chapter_slug=chapter.slug)

    if request.method == "POST":
        form = ChapterFeedbackForm(
            request.POST, initial={"chapter": chapter, "user": request.user if request.user.is_authenticated else None}
        )
        if form.is_valid():
            feedback = form.save()
            send_feedback_email(feedback)
            return render(
                request,
                "course/feedback_form_success.html",
                context,
            )
    else:
        form = ChapterFeedbackForm()

    context.update({"form": form})
    return render(request, "course/feedback_form.html", context)
