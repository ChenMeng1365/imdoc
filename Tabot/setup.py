#coding:utf-8
from setuptools import setup, find_packages

setup(
    name="tabot",
    version="0.3",
    packages=find_packages(),
    install_requires=[
        'xlrd', 'xlwt', 'pandas'
    ],
    py_modules=['tabot','pantab'],

    author='Matthrewchains',
    author_email='matthrewchains@gmail.com',
    description='Its a tool for excel worksheet.',
    # long_description=open('README.md').read(),
    # long_description_content_type='text/markdown',
    url='http://127.0.0.1/',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
    python_requires='>=3.6',
)
