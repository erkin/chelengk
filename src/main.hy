(import [playback [play-tune]]
        [songs [read-song-from-library]])

(defmain [&rest args]
  (play-tune (read-song-from-library "ussak--turku--sofyan--uzun_ince--asik_veysel.txt")))
