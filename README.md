# Applied Poetics API

A constraint-based text processing API built with Ruby on Rails 8+. Provides literary, linguistic, numerical, and topical text analysis tools through both REST and MCP (Model Context Protocol) interfaces.

**Base URL:** `https://api.appliedpoetics.org`

The application serves both a REST API and an MCP (Model Context Protocol) server from the same domain. REST endpoints are at `/v1/:category/:method` and the MCP endpoint is at `/v1/mcp`.

---

## Table of Contents

- [Getting Started](#getting-started)
- [REST API](#rest-api)
  - [Authentication](#authentication)
  - [Request Format](#request-format)
  - [Response Format](#response-format)
  - [Categories](#categories)
    - [Syntax](#syntax)
    - [Grammar](#grammar)
    - [Oulipean](#oulipean)
    - [Numerology](#numerology)
    - [Pop](#pop)
    - [Algorithmic](#algorithmic)
    - [Formic](#formic)
  - [Error Handling](#error-handling)
- [MCP Server](#mcp-server)
  - [Supported Methods](#supported-methods)
  - [Tool Discovery](#tool-discovery)
  - [Tool Invocation](#tool-invocation)
  - [Resources](#resources)
  - [Client Configuration](#client-configuration)
- [Data Sets](#data-sets)
- [Development](#development)
- [Running Tests](#running-tests)

---

## Getting Started

### Prerequisites

- Ruby 4.0+
- Rails 8.1.3+
- Bundler

### Installation

```bash
git clone https://github.com/appliedpoetics/api.appliedpoetics.org.git
cd api.appliedpoetics.org
bundle install
bin/rails db:create db:migrate
bin/rails server
```

The application runs on port 3000 internally and is exposed on port 443 via `app.yaml`.

---

## REST API

All REST endpoints are prefixed with `/v1/:category/:method` and accept `POST` requests with form-encoded or JSON body parameters.

### Authentication

No authentication is currently required for the public API.

### Request Format

```bash
curl -X POST https://api.appliedpoetics.org/v1/syntax/concordance \
  -H "Content-Type: application/json" \
  -d '{
    "text": "the quick brown fox jumps over the lazy dog",
    "word": "fox",
    "context": 1
  }'
```

### Response Format

Every successful response returns a JSON object with a `result` key:

```json
{
  "result": "brown fox jumps"
}
```

Error responses return HTTP 400 Bad Request with an `error` message:

```json
{
  "error": "param is missing or the value is empty or invalid: word"
}
```

---

### Categories

#### Syntax

Textual analysis and structural pattern matching.

| Method | Description | Parameters |
|--------|-------------|------------|
| `concordance` | Finds occurrences of a word with surrounding context | `text`, `word`, `context` |
| `abecedarian` | Selects words in alphabetical order by first letter | `text` |
| `abcquence` | Selects words whose letters are in alphabetical order | `text` |
| `chain_reaction` | Links words where the last letter of one matches the first of the next | `text` |
| `anagram` | Replaces words with dictionary anagrams when available | `text` |
| `alternator` | Selects words that alternate between vowels and consonants | `text` |
| `hexwords` | Translates words into hex-style leetspeak spellings | `text` |

**Example — Concordance:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/syntax/concordance \
  -d 'text=the quick brown fox jumps over the lazy dog' \
  -d 'word=fox' \
  -d 'context=1'
```

Response: `{"result": "brown fox jumps\n"}`

---

#### Grammar

Punctuation, part-of-speech, and grammatical analysis.

| Method | Description | Parameters |
|--------|-------------|------------|
| `punctuator` | Extracts only punctuation marks from text | `text` |
| `isolator` | Filters text fragments by ending punctuation | `text`, `punctuation` |
| `quotations` | Extracts text inside double quotes | `text` |
| `parts_of_speech` | Extracts words by grammatical category | `text`, `tag` |

Valid `tag` values for `parts_of_speech`: `adjectives`, `adverbs`, `base_present_verbs`, `comparative_adjectives`, `conjunctions`, `gerund_verbs`, `infinitive_verbs`, `interrogatives`, `max_noun_phrases`, `noun_phrases`, `nouns`, `passive_verbs`, `past_tense_verbs`, `present_verbs`, `proper_nouns`, `question_parts`, `superlative_adjectives`, `verbs`, `words`

**Example — Parts of Speech:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/grammar/parts_of_speech \
  -d 'text=The quick brown fox jumps.' \
  -d 'tag=nouns'
```

Response: `{"result": "fox"}`

---

#### Oulipean

Literary constraints inspired by the Oulipo (Ouvroir de litterature potentielle) movement.

| Method | Description | Parameters |
|--------|-------------|------------|
| `lipogram` | Excludes words containing specified letters | `text`, `letters` |
| `tautogram` | Includes only words containing specified letters | `text`, `letters` |
| `homoconsonantism` | Excludes words containing vowels | `text` |
| `fibonacci` | Selects words at Fibonacci positions | `text` |
| `prisoner` | Excludes words with letters that descend below the baseline | `text` |
| `belle_absente` | Excludes words containing specified letters | `text`, `letters` |
| `beau_presente` | Includes only words containing specified letters | `text`, `letters` |
| `univocalism` | Removes words containing unwanted vowels | `text`, `letters` |
| `snowball` | Sorts words by length in ascending or descending order | `text`, `order` |

**Example — Lipogram:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/oulipean/lipogram \
  -d 'text=the quick brown fox' \
  -d 'letters=e'
```

Response: `{"result": "quick brown fox"}`

---

#### Numerology

Number-based text selection and calculation.

| Method | Description | Parameters |
|--------|-------------|------------|
| `nth` | Selects every nth word from the text | `text`, `n` |
| `pithon` | Returns pi to as many decimal places as there are words | `text` |
| `length` | Selects words of a specific letter count | `text`, `n` |
| `birthday` | Selects words using birthdate digits as step values | `text`, `birthdate` |
| `phonewords` | Selects words spellable on a phone keypad | `text`, `phone` |

**Example — Pithon:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/numerology/pithon \
  -d 'text=one two three four five'
```

Response: `{"result": "3.14159"}`

**Example — Birthday:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/numerology/birthday \
  -d 'text=alpha bravo charlie delta echo foxtrot golf hotel india juliet' \
  -d 'birthdate=03-14-1985'
```

Response: `{"result": "alpha delta echo india juliet india golf bravo bravo echo"}`

---

#### Pop

Topical and real-world-data-driven text selection.

| Method | Description | Parameters |
|--------|-------------|------------|
| `powerball` | Selects words using NY lottery Powerball numbers as step values | `text` |
| `weatherizer` | Selects sentences containing weather terminology | `text` |
| `colorizer` | Selects sentences containing color names | `text` |
| `sartorializer` | Selects sentences containing fashion and clothing terms | `text` |

**Example — Weatherizer:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/pop/weatherizer \
  -d 'text=The sun is shining. I walked to the store. A storm is coming.'
```

Response: `{"result": "The sun is shining. A storm is coming."}`

**Example — Sartorializer:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/pop/sartorializer \
  -d 'text=She wore a silk dress. The weather was nice. He had on leather boots.'
```

Response: `{"result": "She wore a silk dress. He had on leather boots."}`

---

#### Algorithmic

Computational and distance-based text analysis.

| Method | Description | Parameters |
|--------|-------------|------------|
| `levenshtein` | Finds word pairs within a given edit distance | `text`, `distance` |
| `color_field` | Analyzes image colors and filters text accordingly | `text`, `image`, `mode` |

Valid `mode` values for `color_field`: `sentences`, `letters`, `anagrams`, `list`

---

#### Formic

Poetic form generation and rearrangement.

| Method | Description | Parameters |
|--------|-------------|------------|
| `sestina` | Arranges end-words into a sestina pattern | `text` |
| `triolet` | Arranges lines into a triolet form | `text` |
| `pantoum` | Arranges lines into a pantoum form | `text` |

**Example — Sestina:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/formic/sestina \
  -d 'text=mountain river valley canyon desert plain'
```

---

### Error Handling

| Status | Meaning |
|--------|---------|
| 200 | Success |
| 400 | Bad Request — missing or invalid parameters |

Missing required parameters return HTTP 400 with a JSON error body describing the missing key.

---

## MCP Server

The API also functions as an MCP (Model Context Protocol) server, enabling AI assistants like Claude, Cursor, and VS Code to discover and invoke tools dynamically.

**MCP Endpoint:** `POST https://api.appliedpoetics.org/v1/mcp`

### Supported Methods

| Method | Description |
|--------|-------------|
| `initialize` | Handshake — returns server capabilities |
| `tools/list` | Returns all available tools with schemas |
| `tools/call` | Invokes a tool by name with arguments |
| `resources/list` | Lists available data resources |
| `resources/read` | Returns contents of a data resource |

### Tool Discovery

MCP tools are named `{category}_{method}` (e.g., `pop_weatherizer`, `numerology_birthday`). All 29+ tools are automatically discovered from the service classes.

### Tool Invocation

**Request:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "tools/call",
    "params": {
      "name": "pop_sartorializer",
      "arguments": {
        "text": "She wore a silk dress. The weather was nice."
      }
    }
  }'
```

**Response:**

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      { "type": "text", "text": "She wore a silk dress." }
    ],
    "isError": false
  }
}
```

### Resources

Data files exposed as MCP resources:

| URI | Description |
|-----|-------------|
| `data://colors.txt` | CSS color names with RGB values |
| `data://weather_terms.txt` | Comprehensive meteorological terminology (~200 terms) |
| `data://fashion_terms.txt` | Clothing and fashion terminology (~250 terms) |
| `data://words_alpha.txt` | Alphabetical English word dictionary |

**Read a resource:**

```bash
curl -X POST https://api.appliedpoetics.org/v1/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "resources/read",
    "params": {
      "uri": "data://weather_terms.txt"
    }
  }'
```

### Client Configuration

#### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "applied-poetics": {
      "url": "https://api.appliedpoetics.org/v1/mcp"
    }
  }
}
```

#### VS Code / Cursor

Add to settings:

```json
{
  "mcp": {
    "servers": {
      "applied-poetics": {
        "url": "https://api.appliedpoetics.org/v1/mcp"
      }
    }
  }
}
```

Once configured, AI assistants can use prompts like:

> "Run the sartorializer on this paragraph."  
> "Use the weatherizer to find meteorological references."  
> "Generate a lipogram excluding the letter E."

---

## Data Sets

Static data files in `data/`:

- `colors.txt` — CSS color names with RGB values (used by Colorizer and ColorField)
- `weather_terms.txt` — Meteorological terminology (used by Weatherizer)
- `fashion_terms.txt` — Clothing and fashion terms (used by Sartorializer)
- `words_alpha.txt` — English word dictionary (used by Anagram)

---

## Development

### Project Structure

```
app/
  controllers/v1/
    application_controller.rb   # REST API controller
    mcp_controller.rb           # MCP server controller
  services/
    constraint.rb               # Generic constraint router
    syntax.rb                   # Syntax tools
    grammar.rb                  # Grammar tools
    oulipean.rb                 # Oulipean constraint tools
    numerology.rb               # Numerical tools
    pop.rb                      # Topical/data-driven tools
    algorithmic.rb              # Computational tools
    formic.rb                   # Poetic form tools
    mcp_tool_registry.rb        # MCP tool discovery
config/
  routes.rb                     # REST and MCP routes
data/
  colors.txt
  weather_terms.txt
  fashion_terms.txt
  words_alpha.txt
test/
  services/                     # Unit tests for each category
  controllers/v1/               # Integration tests
```

### Running Tests

```bash
# Run all tests
bin/rails test

# Run a specific test file
bin/rails test test/services/numerology_test.rb
bin/rails test test/controllers/v1/mcp_controller_test.rb

# Run with coverage
bin/rails test
# Coverage report: coverage/index.html
```

---

## Privacy Policy

Applied Poetics does not store, sell, or share the text submitted through this API. Inputs are processed ephemerally in memory and discarded immediately after a response is returned. Server logs are retained for no more than 30 days for operational monitoring and abuse prevention.

For the full policy, see [PRIVACY.md](PRIVACY.md).

---

## License

MIT
