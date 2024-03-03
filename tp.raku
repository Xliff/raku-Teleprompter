use v6.c;

use GLib::Timeout;

use Cro::HTTP::Client;
use DOM::Tiny;
use GTK::Raw::Types;

use GTK::Application;
use GTK::CSSProvider;
use GTK::ScrolledWindow;
use GTK::TextView;

my $default;

sub MAIN (
   $source?          is copy,
  :$selector,
  :$width                      = 2048,
  :$height                     = 768,
  :$background-color is copy   = 'black',
  :$color            is copy   = 'white',
  :$font                       = 'DejaVu Sans 36',
  :$speed            is copy   = 0.05
) {
  my $paused = False;

  my $a = GTK::Application.new(
     title  => 'org.genex.teleprompter',
    :$width,
    :$height
  );

  my $css = GTK::CSSProvider.new;
  sub set-color {
    my $css-s = qq:to/CSS/;
      #tview text \{
        color:            { $color };
        background-color: { $background-color };
      \}
      CSS

    $css.load_from_data($css-s);
  }

  $a.activate.tap( -> *@a {
    my %opts = (
      name      => 'tview',
      wrap-mode => GTK_WRAP_WORD # Word wrap on word
    );

    %opts<text> = do given $source {
      when .defined.not {
        $default
      }

      when .starts-with('http://' | 'https://') {
        my $r = await Cro::HTTP::Client.get($source);
        my $b = await $r.body;
        if $selector {
          my $d = DOM::Tiny.parse($b);
          $b = $d.find($selector);
        }
        $b;
      }

      default {
        .IO.slurp
      }
    }

    my $v  = GTK::TextView.new( |%opts );
    my $fd = $v.set-font($font);
    my $s  = GTK::ScrolledWindow.new;

    $v.key-press-event.tap: sub ($, $e, *@) {
      given $e.keyval {
        # UP         = Size + 10
        # Shift + UP = Size + 1
        when GDK_KEY_Up    {
          $fd.size += $e.&isShift ?? 1 !! 10;
          $v.set-font($fd)
        }

        # DOWN         = Size - 10
        # Shift + DOWN = Size - 1
        when GDK_KEY_Down  {
          $fd.size -= $e.&isShift ?? 1 !! 10;
          $v.set-font($fd)
        }

        # Color Invert
        when GDK_KEY_I | GDK_KEY_i {
          ($background-color, $color) = ($color, $background-color);
          set-color;
        }

        # Speed+
        when GDK_KEY_Page_Up {
          $fd.speed += $e.^isShift ?? 1 !! 0.10;
        }

        # Speed-
        when GDK_KEY_Page_Down {
          $fd.speed -= $e.^isShift ?? 1 !! 0.10;
        }

        # Pause = Space
        when GDK_KEY_Space {
          $pause .= not
        }

        # Q = Quit
        when GDK_KEY_Q | GDK_KEY_q {
          $a.quit( :qio )
        }
      }
    }

    my $adj = $v.vadjustment;
    $s.add($v);
    $a.window.add($s);
    $a.window.show-all;

    # Scroll
    GLib::Timeout.add(1, SUB {
      CATCH {
        default { .message.say; .backtrace.concise.say }
      }

      unless $paused {
        $adj.value     += $speed;
        $v.vadjustment  = $adj;
      }
      G_SOURCE_CONTINUE
    });
  });

  $a.run;
}

INIT {
  $default = q:to/LOREM/;
    Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Blandit cursus risus at ultrices mi tempus imperdiet nulla. Nisl condimentum id venenatis a condimentum vitae. Faucibus pulvinar elementum integer enim neque volutpat ac. Vitae et leo duis ut diam quam nulla porttitor massa. Mi proin sed libero enim sed faucibus turpis. Cursus turpis massa tincidunt dui ut. Faucibus scelerisque eleifend donec pretium vulputate. Sem integer vitae justo eget. Posuere lorem ipsum dolor sit amet consectetur adipiscing elit. Mauris in aliquam sem fringilla ut morbi. Iaculis eu non diam phasellus vestibulum lorem sed. Habitant morbi tristique senectus et netus et malesuada fames. Eget magna fermentum iaculis eu non. Eu mi bibendum neque egestas congue quisque egestas diam in.

    Tempus iaculis urna id volutpat lacus laoreet non. Malesuada proin libero nunc consequat interdum varius sit amet mattis. Orci nulla pellentesque dignissim enim sit amet venenatis. Sapien et ligula ullamcorper malesuada proin. Morbi tincidunt augue interdum velit. Non quam lacus suspendisse faucibus interdum posuere. Sem fringilla ut morbi tincidunt augue interdum velit. Semper quis lectus nulla at volutpat diam ut venenatis. Turpis tincidunt id aliquet risus feugiat in ante metus dictum. Vehicula ipsum a arcu cursus. Proin nibh nisl condimentum id venenatis a. Sagittis purus sit amet volutpat consequat mauris nunc congue nisi. In ornare quam viverra orci sagittis eu volutpat odio.

    Morbi enim nunc faucibus a pellentesque. Erat imperdiet sed euismod nisi porta lorem mollis. Malesuada bibendum arcu vitae elementum. Pellentesque diam volutpat commodo sed egestas egestas fringilla phasellus. Ornare arcu dui vivamus arcu felis bibendum ut. Montes nascetur ridiculus mus mauris vitae ultricies leo integer. Feugiat in ante metus dictum at. Fermentum dui faucibus in ornare quam viverra orci. Nibh mauris cursus mattis molestie a iaculis. Eget arcu dictum varius duis.

    Amet mauris commodo quis imperdiet massa tincidunt nunc pulvinar sapien. Ullamcorper sit amet risus nullam eget. Vitae semper quis lectus nulla at volutpat diam ut venenatis. Dolor sed viverra ipsum nunc aliquet. Nisi est sit amet facilisis magna etiam tempor orci. Facilisi morbi tempus iaculis urna id volutpat lacus laoreet. Nisl suscipit adipiscing bibendum est ultricies integer. Justo eget magna fermentum iaculis eu non. Eget mi proin sed libero. In hac habitasse platea dictumst vestibulum rhoncus. Lorem ipsum dolor sit amet consectetur adipiscing elit. Tristique magna sit amet purus gravida quis blandit turpis. Congue quisque egestas diam in arcu cursus euismod quis viverra. Integer vitae justo eget magna fermentum iaculis eu non diam. Blandit cursus risus at ultrices mi tempus imperdiet nulla malesuada. Et netus et malesuada fames ac. Dui vivamus arcu felis bibendum ut tristique et egestas quis. Non enim praesent elementum facilisis leo vel. Vestibulum rhoncus est pellentesque elit. Arcu vitae elementum curabitur vitae.

    Ipsum dolor sit amet consectetur adipiscing elit pellentesque. Eu consequat ac felis donec. Arcu vitae elementum curabitur vitae nunc sed velit. Lectus proin nibh nisl condimentum id venenatis. Eu facilisis sed odio morbi quis commodo odio aenean sed. Et egestas quis ipsum suspendisse ultrices. Ipsum suspendisse ultrices gravida dictum. Quis enim lobortis scelerisque fermentum dui faucibus in. At augue eget arcu dictum varius duis. Nam aliquam sem et tortor consequat id porta. Blandit turpis cursus in hac. Faucibus scelerisque eleifend donec pretium vulputate sapien. Eget nullam non nisi est sit. Nisl rhoncus mattis rhoncus urna neque viverra justo.

    Cursus risus at ultrices mi tempus. Eget arcu dictum varius duis at consectetur. Risus feugiat in ante metus dictum at tempor commodo ullamcorper. Est velit egestas dui id ornare arcu odio ut sem. Imperdiet sed euismod nisi porta lorem mollis aliquam ut. Ullamcorper eget nulla facilisi etiam dignissim. Egestas fringilla phasellus faucibus scelerisque eleifend. Vitae sapien pellentesque habitant morbi tristique senectus et. Eu facilisis sed odio morbi quis commodo. Libero id faucibus nisl tincidunt. Dolor purus non enim praesent elementum facilisis leo vel. Sit amet dictum sit amet justo. Nulla porttitor massa id neque aliquam vestibulum morbi blandit. Pharetra diam sit amet nisl suscipit. A erat nam at lectus urna duis convallis convallis tellus. In nibh mauris cursus mattis molestie a. Molestie ac feugiat sed lectus.

    Faucibus a pellentesque sit amet porttitor eget dolor morbi non. Aliquam sem fringilla ut morbi. Nunc vel risus commodo viverra. Magna eget est lorem ipsum dolor sit amet consectetur adipiscing. Ornare quam viverra orci sagittis. Felis bibendum ut tristique et egestas quis. Varius duis at consectetur lorem donec massa sapien. Viverra tellus in hac habitasse platea dictumst vestibulum. Feugiat nisl pretium fusce id velit ut tortor pretium viverra. Nulla pharetra diam sit amet nisl suscipit. A iaculis at erat pellentesque adipiscing commodo elit at imperdiet. Sit amet nisl purus in mollis. Nulla porttitor massa id neque. Nec nam aliquam sem et tortor. Pharetra magna ac placerat vestibulum lectus. Arcu felis bibendum ut tristique et egestas quis. Eu feugiat pretium nibh ipsum consequat nisl. Quis blandit turpis cursus in hac. Nam libero justo laoreet sit amet cursus. Massa ultricies mi quis hendrerit dolor magna eget est lorem.

    Bibendum enim facilisis gravida neque convallis a cras semper. Hendrerit dolor magna eget est lorem ipsum. Consequat mauris nunc congue nisi vitae suscipit tellus mauris. Sed lectus vestibulum mattis ullamcorper velit sed ullamcorper. Vitae tortor condimentum lacinia quis vel eros donec. In nisl nisi scelerisque eu. Sagittis vitae et leo duis. Velit scelerisque in dictum non. Tempus imperdiet nulla malesuada pellentesque elit eget. Lectus urna duis convallis convallis tellus id interdum velit. Habitant morbi tristique senectus et netus et malesuada fames. Ut ornare lectus sit amet est placerat in egestas. Sollicitudin ac orci phasellus egestas tellus. Risus sed vulputate odio ut. Semper auctor neque vitae tempus quam pellentesque nec nam. Neque gravida in fermentum et sollicitudin ac orci phasellus egestas. Ac feugiat sed lectus vestibulum mattis ullamcorper velit sed ullamcorper. Eu nisl nunc mi ipsum faucibus vitae aliquet nec. Luctus venenatis lectus magna fringilla urna porttitor rhoncus. Id semper risus in hendrerit gravida.
    LOREM
  }
