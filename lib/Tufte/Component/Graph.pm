use Tufte::Component::Base;

class Tufte::Component::Graph is Tufte::Component::Base {
    our $STACKED_OPACITY = 0.85;

    multi method draw(%bounds, %options) {
	my @applicable_layers = gather {
	    for %options<layers> -> $l {
		take $l unless %!options<only>;

		take $l if $l.options<category> || $l.options<categories>;
		take $l if $l.options<category> && $l.options<category> != %!options<only>;
		take $l if $l.options<categories> && $l.options<categories> !~~ %!options<only>;
	    }
	}
	for @applicable_layers.kv -> $idx, $layer {
	    my %layer_options = index => $idx,
		min_value  => %options<min_value>, max_value => %options<max_value>,
		complexity => %options<complexity>;
		size       => (%bounds<width>, %bounds<height>),
		color      => $layer.preferred_color || $layer.color || %options<theme>.next_color,
		opacity    => $.opacity_for($idx), theme => %options<theme>;

	    $!svg.drawings.push: :g[
		id => "component_{$!id}_graph_$idx", :class<graph_layer>,
		$layer.render(%layer_options)];
	}
	$!svg.drawings;
    }

    multi method opacity_for($idx) {
	$idx == 0 ?? 1.0 !! (%!options<stacked_opacity> || $STACKED_OPACITY);
    }
}

# vim: ft=perl6
