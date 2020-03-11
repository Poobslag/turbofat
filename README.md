# Turbo Fat
A block-dropping puzzle game. This is inspired by a few other block-dropping games but breaks some rules.

  * Most games reward you for tidy horizontal stacks, but Turbo Fat rewards you for messy vertical stacks.
  * Most games punish you for leaving horizontal crevices in your stack, but Turbo Fat encourages you to create these types of crevices and lets you squeeze pieces into them.
  * Most games reward making a tall narrow column where you can clear multiple lines at once, but Turbo Fat punishes this. There are no 'line pieces' and you do not score bonus points for simultaneous line clears.
  * Most games reward you for building a mountain of blocks, and tearing it down with a big combo. Turbo Fat allows this, but you can also sustain a combo while keeping the same number of blocks on your screen. You can even start a combo when your screen is empty, and fill up your screen while comboing.
  * Most games limit your combo by the number of blocks on the screen. In Turbo Fat, combos can continue forever.

While this game is still in development, my goal is for it to include three different modes:

  * A sustained marathon mode which lasts about 10 minutes, and the player is graded based on their performance. They might aspire to get a 'grand master' grade by playing better.
  * Several shorter sprint modes which last about 3 minutes, and the player is given a score or a time. They might aspire to finish faster or score more points.
  * A story mode made up of a wide variety of 3 minute scenarios. Some scenarios reward the player for learning basic game concepts and playing better. Other scenarios force the player to adapt to unusual scenario-specific rules. Some mandatory scenarios block the player's progress until they're able to clear them.

# How to play

Press the directional keys to control the piece, and the rotate keys (Z, X) to rotate the piece. Arrange your pieces into complete rows to clear lines and score points. Arrange your pieces into 3x3, 3x4 or 3x5 squares to form boxes, which award you additional points for line clears.

## Playing faster

### Piece movement and rotation

Holding a direction lets you move the piece quickly to one side of the playfield.

Rotated pieces will try to reposition themselves to avoid obstructions. For quadrominos (4-size pieces), traditional rotation rules apply which allows for shenanigans such as T-spin triples.

### Soft dropping

Pressing the soft-drop button (down) will lower a piece more rapidly. You can hold a diagonal direction to slide the piece into a nook underneath another piece, even if it's two spaces over.

Holding the soft-drop button will attempt to pass a piece through obstructions in the playfield. This only work if at least one block in the current piece has a clear path to its new location. You can also tap the soft-drop button when the piece is obstructed to do the same thing.

### Hard dropping

Pressing the hard-drop button (up) will plummet the piece to the bottom of the playfield and lock it into place. However, you can cancel it from locking or squish the piece further down by tapping the soft-drop button. To facilitate this, hard-drop is bound to both up and shift. For example. you can press shift to hard-drop a piece, down to unlock it, and right to slide it over.

### Buffering moves

Holding a left or right when a piece spawns will immediately spawn the piece on the left or right side of the playfield. The piece doesn't even move there, it just *appears* there, so you can do this if you're about to die or if there are blocks in the way.

Holding a rotate button when a piece spawns will immediately rotate the piece into that orientation. You can use this to keep from dying, if the piece's normal orientation would kill you. If you want to rotate a piece upside-down, you can hold both rotate buttons when the piece spawns.

Holding the hard-drop button when a piece spawns will immediately hard-drop the piece. This can be combined with other buffered moves. For example, you might hold hard-drop, both rotate buttons, and left in order to spawn the piece flipped on the left side of the playfield.

## Scoring more points

### Combos

Clearing two or more lines sequentially forms a combo which scores you bonus points. The second and third line clear award 5 bonus points, the fourth and fifth award 10 points, the sixth and seventh award 15 points, and each subsequent line clear award 20 points. Combos are retained if you drop a piece without clearing a line, but the second piece will reset the combo.

There are no special bonus points for clearing multiple lines at once, but each line counts towards your combo and awards bonus points in that way. For example, clearing 3 lines at once earns you 10 bonus points, which is the same which you earn from clearing 3 lines sequentially (0, +5, +5).

### Boxes

Arranging a quadromino and pentomino into a 3x3 square will turn them into a snack box. Snack boxes award 5 points every time you clear a line with them, for a total of +15 points if you clear all three lines.

Arranging three quadrominos into a 3x4 rectangle will turn them into a cake box. Cake boxes award 10 bonus points every time you clear a line with them, for a total of +40 points if you clear all four lines. These can be oriented horizontally, but you'll only score +30 points as the box have fewer lines.

You can also form a cake box by arranging three pentominos into a 3x5 rectangle, which still awards 10 bonus points per line. Any other sizes of rectangles, such as a 3x6 rectangle or 4x4 square will not form a box.

You can have several snack boxes and cake boxes per line, and these bonuses can combine with your combo bonus. For example if you arrange 6 pieces into 3 snack boxes, and the sixth piece clears all three rows, you would earn +10 points for combo, and +45 bonus points for the boxes. You could earn up to +50 bonus points with a single line clear, although this is very difficult.

Forming a box prevents your combo from being interrupted. A skilled player can theoretically continue their combo indefinitely if they continue clearing lines and forming boxes.

# How am I being graded?

After you finish the game, you're graded in a few categories:

  * **Lines:** How many lines you cleared, ignoring bonus points. Surviving longer gets you a better grade.
  * **Speed:** How many lines you cleared per second, ignoring bonus points. Playing faster gets you a better grade.
  * **Boxes:** How many bonus points you obtained per line from clearing boxes you made. Making lots of boxes gets you a better grade, especially having multiple boxes side-by-side or going for high-scoring cake boxes.
  * **Combos:** How many bonus points you obtained per line from combos. Keeping your combo up by clearing lines and making boxes gets you a better grade.
  * **Time:** Ultra mode grades you on your overall time, faster is better. Your other grades do not affect this overall grade.
  * **Score:** Sprint and Marathon modes grade you on your overall score, higher is better. Your other grades do not affect this overall grade.

# Glossary

Here's a glossary of terms used within the code. When editing code, try to use consistent terms like "arrange two pieces into a box" instead of "arrange two blocks into a food item", or "whenever the player sees" instead of "whenever you see"

**box:** a 3x3, 3x4 or 3x5 rectangle built from intact pieces.

**block:** a solid element occupying one cell of the playfield.

**cake box:** a 4x3 or 5x3 rectangle built from either three pentominos or three quadrominos. Also 'rainbow cake' or 'rainbow box'.

**cell:** a unit square within the playfield.

**line:** a horizontal row of blocks.

**piece:** a set of blocks that moves as a unit. 

**player:** the person playing the game.

**playfield:** the grid of cells into which pieces are placed. 

**snack box:** a 3x3 square built from a pentomino and a quadromino.
