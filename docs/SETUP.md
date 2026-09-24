## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```
3. Set up the database:
   ```bash
   rails db:create db:migrate
   ```
4. Import initial content:
   ```bash
   rails import:all
   ```
5. Start the development server:
   ```bash
   ./bin/dev
   ```

## Content Import

The application comes with predefined content that can be imported using rake tasks:

```bash
rails import:perspectives        # Import narrative perspectives
rails import:archetypes         # Import character archetypes
rails import:personality_traits # Import personality traits
rails import:moral_alignments   # Import moral alignments
rails import:narrative_structures # Import story structures
rails import:character_types    # Import character types
rails import:locations         # Import location types
```
