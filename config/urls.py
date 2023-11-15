from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path
from django.views import defaults as default_views

urlpatterns = [
    path("", include("pyoneers_platform.home.urls")),
    path("admin/", admin.site.urls),
    path("users/", include("pyoneers_platform.users.urls", namespace="users")),
    path("course/", include("pyoneers_platform.course.urls", namespace="course")),
    path("", include("allauth.urls")),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

if settings.DEBUG:
    # This allows the error pages to be debugged during development, just visit
    # these url in browser to see how these error pages look like.
    urlpatterns += [
        path(
            "400/",
            default_views.bad_request,
            kwargs={"exception": Exception("Bad Request!")},
        ),
        path(
            "403/",
            default_views.permission_denied,
            kwargs={"exception": Exception("Permission Denied")},
        ),
        path(
            "404/",
            default_views.page_not_found,
            kwargs={"exception": Exception("Page not Found")},
        ),
        path("500/", default_views.server_error),
    ]
    if "silk" in settings.INSTALLED_APPS:
        urlpatterns += [path("silk/", include("silk.urls", namespace="silk"))]

        urlpatterns = [path("__debug__/", include(debug_toolbar.urls))] + urlpatterns

    # TODO: Implement django-browser-reload
    # if "django_browser_reload" in settings.INSTALLED_APPS:
    #     urlpatterns = [
    #         path("__reload__/", include("django_browser_reload.urls"))
    #     ] + urlpatterns
