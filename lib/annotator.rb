class Annotator
  attr_accessor :w
  def initialize
    @w,@notes = [],[]
  end
  def annotate(expr,note='')
    note = @notes.shift if not @notes.empty?
    @w.push({:expr=>expr,:note=>note})
  end
  def queue_note(note)
    @notes.push(note)
  end
  def to_s
    @w.join("\n")
  end
  def purge_empty_notes!
    @w.delete_if do |e|
      e[:note] == ''
    end
  end
end