namespace :export do
  desc 'Export book chapters to markdown files'
  task :book_to_markdown, [:book_id] => :environment do |_t, args|
    # Support both argument styles: rake export:book_to_markdown[2] and BOOK_ID=2 rake export:book_to_markdown
    book_id = args[:book_id] || ENV['BOOK_ID']

    unless book_id
      puts "\nError: Please provide a book_id using one of these methods:"
      puts "\nOption 1 (for bash):"
      puts "  rake export:book_to_markdown[2]"
      puts "\nOption 2 (for zsh):"
      puts "  rake 'export:book_to_markdown[2]'"
      puts "\nOption 3 (works in all shells):"
      puts "  BOOK_ID=2 rake export:book_to_markdown"
      exit 1
    end

    book = Book.find_by(id: book_id)

    unless book
      puts "Error: Book with id #{book_id} not found"
      exit 1
    end

    # Create book directory if it doesn't exist
    book_dir = Rails.root.join('book')
    FileUtils.mkdir_p(book_dir)
    FileUtils.touch(book_dir.join('.keep'))

    # Delete any existing files in the book directory
    Dir.glob(book_dir.join('*.md')).each { |file| File.delete(file) }

    # Export each chapter
    book.chapters.order(:number).each do |chapter|
      # Format the filename with padded number and sanitized name
      filename = format('%02d_%s.md', chapter.number, chapter.name.downcase.gsub(/[^0-9a-z]/i, '_'))

      # Write the chapter content to a file
      File.write(book_dir.join(filename), chapter.content)

      puts "Exported: #{filename}"
    end

    puts "\nExport completed successfully!"
    puts "Files are located in: #{book_dir}"
  end
end
