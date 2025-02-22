# Application Analysis Notes

## Project Overview
- Rails application for managing book writing and character development
- Uses Vite.js for frontend assets
- Uses Tailwind CSS for styling
- Has background job processing for AI-assisted content generation
- Uses YAML blueprints for importing predefined content

## Development Guidelines
- Documentation Synchronization: The project uses a Cursor rule that requires running './bin/compose_docs' before commits
- This script analyzes the codebase and updates both technical documentation (notes.md) and user documentation (README.md)
- The analysis covers:
  - Models and their relationships
  - Controllers and their endpoints
  - Background jobs and their purposes
  - Rake tasks and their functions
- Changes to any of these components require documentation synchronization

## Models

### Core Models

#### Book
- Central model for managing books
- Key attributes:
  - title
  - moral
  - plot
  - chapters
  - pages
- Relationships:
  - belongs_to writing_style
  - belongs_to perspective
  - belongs_to narrative_structure
  - belongs_to protagonist (Character)
  - has_many antagonists through book_antagonists
  - has_and_belongs_to_many characters (regular characters)
- Complex validation logic to ensure characters don't have conflicting roles (can't be protagonist and antagonist simultaneously)

#### Character
- Represents characters in books
- Rich attribute set:
  - name
  - gender
  - age
  - ethnicity
  - nationality
  - appearance
  - health
  - fears
  - desires
  - backstory
  - skills
  - values
- Relationships:
  - has_and_belongs_to_many character_types
  - has_and_belongs_to_many moral_alignments
  - has_and_belongs_to_many personality_traits
  - has_and_belongs_to_many archetypes
  - has_and_belongs_to_many locations
  - has_and_belongs_to_many books
  - Can be protagonist or antagonist in books
- Uses paper_trail for version tracking
- Custom JSON serialization for API responses

### Supporting Models

#### Character-Related Models

##### CharacterType
- Defines different types of characters
- Attributes:
  - name
  - definition
  - purpose
  - example
- Has many-to-many relationship with characters

##### MoralAlignment
- Defines character moral alignments
- Attributes:
  - name
  - description
  - examples (serialized YAML)
- Has many-to-many relationship with characters
- Paginated (100 per page)

##### PersonalityTrait
- Defines character personality traits
- Attributes:
  - name
  - description
- Has many-to-many relationship with characters
- Paginated (100 per page)

##### Archetype
- Defines character archetypes
- Attributes:
  - name
  - traits
  - examples
- Has many-to-many relationship with characters
- Paginated (100 per page)

#### Book-Related Models

##### WritingStyle
- Defines book writing styles
- Attributes:
  - name
  - prompt (JSON serialized)
  - pending flag
- Has many books and texts
- Uses paper_trail for version tracking
- Validates JSON prompt format

##### Perspective
- Defines narrative perspectives
- Attributes:
  - name
  - narrator
  - pronouns
  - effect
  - example
- Has many books
- All attributes required

##### NarrativeStructure
- Defines book narrative structures
- Attributes:
  - name
  - description
  - parts (serialized YAML)
- Has many books
- Requires unique name

## Controllers

### Core Controller Structure

#### MetaController
- Base controller providing common CRUD functionality
- Supports:
  - Listing with pagination
  - Creation
  - Editing
  - Viewing
  - Deletion
  - Prompt generation and iteration (AI-related)
- Handles parent-child relationships
- Manages component paths and naming

### Main Controllers

#### BooksController
- Manages book resources
- Handles relationships with:
  - Writing styles
  - Perspectives
  - Narrative structures
  - Characters (protagonist, antagonists, regular characters)

#### CharactersController
- Manages character resources
- Supports AI-assisted character development through:
  - IterateOnCharacterPromptJob
  - GenerateCharacterPromptJob
- Handles relationships with character attributes (types, alignments, traits, archetypes)

### Supporting Controllers
- MoralAlignmentsController
- NarrativeStructuresController
- PersonalityTraitsController
- PerspectivesController
- CharacterTypesController
- ArchetypesController
- LocationsController
- WritingStylesController

## Background Jobs

### AI Generation Jobs
- GenerateCharacterPromptJob: Creates initial character prompts
- GenerateWritingStyleJob: Creates writing style prompts
- GenerateLocationPromptJob: Creates location prompts

### Iteration Jobs
- IterateOnCharacterPromptJob: Refines character content
- IterateOnWritingStyleJob: Refines writing style content
- IterateOnLocationPromptJob: Refines location content

### Merging Jobs
- MergeCharacterPromptsJob: Combines character-related content
- MergeWritingStylesJob: Combines writing style content
- MergeLocationPromptsJob: Combines location-related content

### Base Jobs
- MetaJob: Base job class with common functionality
- ApplicationJob: Rails application job base class
- AssembleJob: Handles content assembly tasks

## Rake Tasks

### Import Tasks
Imports predefined content from YAML files in the blueprints directory:
- perspectives:import - Narrative perspectives
- archetypes:import - Character archetypes
- personality_traits:import - Character personality traits
- moral_alignments:import - Character moral alignments
- narrative_structures:import - Story narrative structures
- character_types:import - Character type definitions
- locations:import - Story locations

### Asset Tasks
- icons:import - Imports icon assets
- themes:import - Imports theme configurations

## Additional Components
- Uses RSpec for testing
- Uses Rubocop for code style enforcement
- Node.js dependencies present (package.json)
- Uses Semantic UI (semantic.json present)
- Paper Trail for version tracking of key models
- Kaminari for pagination 