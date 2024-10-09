class BooksController < MetaController
  def component_name
    'Books'
  end

  def component_class
    'Book'.constantize
  end

  def component_params
    params.require(@computer_name.to_sym).permit(:title, :writing_style_id, :perspective_id, :narrative_structure_id, :moral,
                                                 :plot, :chapters, :pages)
  end
end
