from setuptools import setup, find_packages

VERSION = '0.2.0' 
DESCRIPTION = 'Handling Pandora IDs in python'
LONG_DESCRIPTION = 'A simple Python package that contains helper functions for handling Pandora IDs'

# Setting up
setup(
        name="pyPandoraHelper", 
        version=VERSION,
        author="Thiseas C. Lamnidis",
        author_email="thiseas_christos_lamnidis@eva.mpg.de",
        description=DESCRIPTION,
        long_description=LONG_DESCRIPTION,
        packages=find_packages(),
        install_requires=[], # add any additional packages that 
        # needs to be installed along with your package. Eg: 'caer'

        keywords=['python', 'pandora'],
        classifiers= [
            "Development Status :: 3 - Alpha",
            "Intended Audience :: Education",
            "Programming Language :: Python :: 3",
            "Operating System :: MacOS :: MacOS X",
            "Operating System :: Microsoft :: Windows",
        ]
)
