from django.core.management.base import BaseCommand, CommandError

from loguru import logger

from pyoneers_platform.course.webhooks import sync_course_with_github


class Command(BaseCommand):
    help = 'Synchronizes the database with the specified GitHub repository'

    def add_arguments(self, parser):
        """
        Adds command-line arguments to the parser.
        """
        # Optional arguments
        parser.add_argument('--repo_url', type=str, help='The URL of the Git repository to clone or pull')
        parser.add_argument('--branch', type=str, help='The branch of the repository to clone or pull')
        parser.add_argument(
            '--local_path', type=str, help='The local directory where the repository will be cloned or pulled'
        )

    def handle(self, *args, **kwargs):
        """
        Executes the command to synchronize the repository.
        """
        # Prepare arguments to be passed
        # Prepare the synchronization operation arguments
        sync_kwargs = {}
        if kwargs.get('repo_url'):
            sync_kwargs['repo_url'] = kwargs['repo_url']
        if kwargs.get('branch'):
            sync_kwargs['branch'] = kwargs['branch']
        if kwargs.get('local_path'):
            sync_kwargs['local_path'] = kwargs['local_path']

        # Execute the synchronization operation
        try:
            # Pass only provided arguments to function
            sync_course_with_github(**sync_kwargs)
            self.stdout.write(self.style.SUCCESS('Successfully synchronized the repository.'))
        except Exception as e:
            logger.error(f'An error occurred: {str(e)}')
            raise CommandError(f'An error occurred: {str(e)}')
