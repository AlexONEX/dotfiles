# quotes.plugin.zsh

# Function to list all quotes 
list_quotes() {
    # Define ANSI color escape codes
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    RESET='\033[0m'

    if [ -f "/home/alex/.quotes.json" ]; then
        jq -r '.[] | "📜 \(.quote | if . then . else "No Quote" end)\n👤 \(.character | if . then . else "Unknown Character" end)\n📚 \(.book | if . then . else "Unknown Book" end)\n"' /home/alex/.quotes.json | fold -w 80 -s | while IFS= read -r line; do
            echo -e "$line"
        done
    else
        echo "No quotes found."
    fi
}

# Function to add a new quote
add_quote() {
    echo "Enter the quote:"
    read -r quote

    echo "Enter the character:"
    read -r character

    echo "Enter the book:"
    read -r book

    # Create a new JSON entry and append it to the quotes.json file
    new_quote="{\"quote\":\"$quote\",\"character\":\"$character\",\"book\":\"$book\"}"

    if [ -f "/home/alex/.quotes.json" ]; then
        jq --argjson newquote "$new_quote" '. += [$newquote]' /home/alex/.quotes.json > quotes_tmp.json
        mv quotes_tmp.json /home/alex/.quotes.json
        echo "Quote added successfully!"
    else
        echo "Quotes file not found."
    fi
}

# Function to remove a quote by index
remove_quote() {
    list_quotes
    echo "Enter the index of the quote to remove:"
    read -r index

    if [ -f "/home/alex/.quotes.json" ]; then
        jq --argjson index "$index" 'del(.[$index])' /home/alex/.quotes.json > quotes_tmp.json
        mv quotes_tmp.json /home/alex/.quotes.json
        echo "Quote removed successfully!"
    else
        echo "Quotes file not found."
    fi
}
