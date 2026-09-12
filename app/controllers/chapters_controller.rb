class ChaptersController < MetaController
  private

  def component_name
    'Chapters'
  end

  def component_class
    'Chapter'.constantize
  end

  def prefix
    'book_'
  end

  def parent_class
    Book
  end

  def iterate_job
    # Placeholder to satisfy MetaController
  end

  def generate_prompt_job
    # Placeholder to satisfy MetaController
  end

  def prompt_attribute_name
    :plot_summary
  end

  def component_params
    params.require(@computer_name.to_sym).permit(
      :plot_summary
    )
  end
end
