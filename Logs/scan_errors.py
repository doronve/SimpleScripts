import re

log_file = sys.argv[1] if len(sys.argv)>1 else "secretName"


# Define your error patterns
error_patterns = [
    r"ERROR: (.+)",
    r"Exception: (.+)",
    # Add more patterns as needed
]

with open(log_file, "r") as f:
    for line in f:
        for pattern in error_patterns:
            match = re.search(pattern, line)
            if match:
                error_message = match.group(1)
                # Define your custom action here based on the error_message
                print(f"Error detected: {error_message}")
                # Execute your action (e.g., send an alert, restart a service, etc.)

