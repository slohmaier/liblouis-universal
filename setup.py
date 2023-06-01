from setuptools import setup, find_packages

setup(
    name='louis',
    version='3.25.0',
    packages=find_packages(),
    package_data={'louis': ['liblouis.dylib', 'tables/*']},
    include_package_data=True,
    # Add more metadata and dependencies as needed
)