class Collection
  attr_accessor :songs

  def initialize(songs_as_string, tags)
    @songs = parse(songs_as_string)
    
    tags.each do |key, value|
      songs_by_artist = @songs.select { |s| s.artist = key }
      songs_by_artist.each { |s| s.tags << value }
    end
  end

  def parse(songs_as_string)
    songs_as_string.lines("\n").map do |string|
      current_song = Song.new(string.split('.'))
      current_song.tags << current_song.genre.downcase 

      if current_song.subgenre
        current_song.subgenre = current_song.subgenre.strip
        current_song.tags << current_song.subgenre.downcase
      end
    end
  end

  def find(criteria)
    @songs.select { |s| s.match?(criteria) }
  end
end

class Song
  attr_accessor :name, :artist, :genre, :subgenre, :tags

  def initialize(song_parts)
    @name, artist = song_parts[0].split(',').map(&:strip)
    @tags = get_tags(song_parts[3])
    @genre = song_parts[2].split(',').first.strip
    @subgenre = song_parts[2].split(',')[1]
  end

  def get_tags(part)
    part ? part.split(',').map(&:strip) : []
  end

  def match?(criteria)
    return false if criteria[:name] and name != criteria[:name]
    return false if criteria[:artist] and artist != criteria[:artist]

    if criteria[:tags]
      matches_tags = check_tags(criteria[:tags])
      return false unless matches_tags
    end

    return false if criteria[:filter] and not criteria[:filter].call(self)

    true
  end

  def check_tags(tags)
    criteria_tags = [*tags]
    including_tags, excluding_tags = split(criteria_tags)

    matches_including_tags = including_tags.all? { |t| @tags.include?(t) }
    matches_excluding_tags = excluding_tags.all? { |t| not @tags.include?(t) }
    matches_including_tags && matches_excluding_tags
  end

  def split(tags)
    including_tags = tags.select { |t| not t.end_with('!') }

    excluding_tags = tags.select { |t| t.end_with('!') }
    excluding_tags = excluding_tags.map { |t| t.chomp('!') }

    [including_tags, excluding_tags]
  end
end