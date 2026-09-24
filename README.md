# Book Rhino - AI-Powered Writing & Production Assistant

Book Rhino is a sophisticated Rails application designed to help movie writers, screenwriters, and film producers use AI to ship books and films. It provides a comprehensive suite of tools for managing narratives, characters, and media, enhanced with AI-powered content generation capabilities.

It includes all the tools you need to:
- Organize your ideas
- Generate prompts
- Organize media
- Produce the final output (be it a book or a film)

## Showcase

Check out these completed projects built with Book Rhino:
- **Book**: [Jealousy in the Jungle: An Invitation for Rivals, An Awakening](https://www.amazon.com/Jealousy-Jungle-Invitation-Rivals-Awakening/dp/B0DY872FHM)
- **Movie**: [Short Film on YouTube](https://www.youtube.com/watch?v=pmE3Yrr0104) | [IMDb Page](https://www.imdb.com/title/tt46763502)

## Features

### Book Management
- Create and manage books with detailed attributes
- Define writing styles and narrative perspectives
- Structure your story with predefined narrative frameworks
- Track chapters and page counts
- Manage relationships between books and characters

### Character Development
- Create rich, detailed character profiles
- Define character attributes:
  - Basic information (name, age, gender, ethnicity, nationality)
  - Physical and health characteristics
  - Psychological traits (fears, desires, values)
  - Skills and abilities
  - Detailed backstories
- Assign character roles (protagonist, antagonist, supporting characters)
- AI-assisted character development and refinement

### Story Elements
- Multiple narrative perspectives with examples and effects
- Character archetypes with traits and examples
- Personality trait library
- Moral alignment system
- Location management with descriptions and examples
- Writing style templates
- Narrative structure frameworks

### AI Integration
- Generate and iterate on character descriptions
- Refine writing styles
- Develop location descriptions
- Merge and assemble content intelligently

### Content Management
- Version tracking for key elements
- Import predefined content from YAML blueprints
- Pagination for large content sets
- Rich text editing capabilities

## Technical Stack

### Backend
- Ruby on Rails
- PostgreSQL database
- Redis for background job processing
- Paper Trail for version tracking
- Kaminari for pagination

### Frontend
- Vite.js for asset management
- Tailwind CSS for styling
- Semantic UI components
- Turbo for dynamic updates

### Development Tools
- RSpec for testing
- Rubocop for code style enforcement
- Node.js for frontend asset compilation

## Setup & Content Import

Please refer to the [Setup Guide](docs/SETUP.md) for installation and content import instructions.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
   - Note: Documentation is automatically maintained by Cursor
   - On each commit, Cursor analyzes the codebase and updates:
     - Technical documentation (notes.md)
     - User documentation (README.md)
   - No manual documentation updates required
4. Push to the branch
5. Create a Pull Request

## License

MIT License

Copyright (c) 2024 Book Rhino

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
