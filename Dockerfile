FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Tools we may need
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Pull official Graphiti repo (includes mcp_server)
RUN git clone --depth 1 https://github.com/getzep/graphiti.git /app/graphiti

WORKDIR /app/graphiti/mcp_server

# Install deps (works whether the folder uses requirements.txt or pyproject)
RUN if [ -f requirements.txt ]; then \
      pip install --no-cache-dir -r requirements.txt; \
    else \
      pip install --no-cache-dir .; \
    fi

# Common default port (we'll set Zeabur port mapping later if needed)
EXPOSE 8000

# Start MCP server (if logs show a different entrypoint, we adjust CMD)
CMD ["sh", "-c", "set -e; cd /app/graphiti/mcp_server; \
  if [ -f main.py ]; then python main.py; \
  elif [ -f server.py ]; then python server.py; \
  elif [ -f app.py ]; then python app.py; \
  elif [ -f run.py ]; then python run.py; \
  elif [ -f mcp_server.py ]; then python mcp_server.py; \
  else echo 'No known entrypoint (main.py/server.py/app.py/run.py/mcp_server.py) found.' && ls -la && exit 1; fi"]

