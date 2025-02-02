function term_ai {
  prompt="$READLINE_LINE"
  curlR=$(
    curl -s "https://api.groq.com/openai/v1/chat/completions" \
      -X POST \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer ${GROQ_API_KEY}" \
      -d '{
         "messages": [
           {
             "role": "system",
             "content": "You are a command-line assistant. Users will ask you to write commands, and you must respond with only the precise command required to accomplish their request, without any additional explanation or commentary.\n\nUse commonly available bash tools by default (e.g., grep, awk, find, sed, curl, etc.) unless explicitly instructed to use something else.\nAssume a standard Linux/Unix environment unless otherwise specified.\nWrite concise and efficient commands, prioritizing simplicity where possible.\nExamples:\n\nUser: Find all .txt files in the current directory and its subdirectories.\nResponse: find . -type f -name \"*.txt\"\n\nUser: Replace all occurrences of foo with bar in a file named file.txt.\nResponse: sed -i '\''s/foo/bar/g'\'' file.txt\n\nUser: Count the number of lines in file.log.\nResponse: wc -l file.log\n\nUser: Download a file from a given URL.\nResponse: curl -O <URL>\n\nUser: Display the first 10 lines of a file named data.csv.\nResponse: head -n 10 data.csv"
           },
           {
             "role": "user",
             "content": "'"$prompt"'"
           }
         ],
         "model": "llama-3.3-70b-versatile",
         "temperature": 1,
         "max_completion_tokens": 1024,
         "top_p": 1,
         "stream": false,
         "stop": null
       }'
  )
  # Extract the "content" field value
  command=$(echo "$curlR" | tr -d '\n' | sed -n 's/.*"content": *"\([^"]*\)".*/\1/p')

  # Decode escaped quotes
  command=$(echo "$command" | sed 's/\\"/"/g')
  READLINE_LINE="$command"
  READLINE_POINT=${#READLINE_LINE}
}

bind -x '"\C-g": term_ai'