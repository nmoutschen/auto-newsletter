FROM public.ecr.aws/lambda/python:3.8

# Install requirements
RUN /var/lang/bin/python3.8 -m pip install --upgrade pip
COPY requirements.txt ./
RUN /var/lang/bin/python3.8 -m pip install --no-cache-dir -r requirements.txt

# Copy lambda code
COPY main.py ./

# Run handler
CMD ["main.handler"]