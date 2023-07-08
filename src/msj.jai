window: Window_Type;
window_width  : s32 = 1280;
window_height : s32 = 720;

Star :: struct {
    quad: Vector4;
    size: Vector2;
    speed: float;
    color: Vector4;
}

stars : [..] *Star;

main :: () {
    #if OS == .WINDOWS {
        Windows :: #import "Windows";
        Windows.SetProcessDPIAware();
	
        // Windows is very bad at thread-switching by default unless you do this. Sad.
        Windows.timeBeginPeriod(1);
    }

    window = create_window(window_width, window_height, "A Window");

    // Actual render size in pixels can be different from the window dimensions 
    // we specified above (for example on high-resolution displays on macOS/iOS).
    window_width, window_height = Simp.get_render_dimensions(window);

    // Init stars
    for index: 0..100 {
            s := New(Star);
            // left, bottom, right, top
            pos := make_vector2(random_get_within_range(0, cast(float)window_width), random_get_within_range(0, cast(float)window_height));
            size :float = random_get_within_range(4, 8);
            s.quad = make_vector4(pos.x, pos.y, pos.x + size, pos.y + size);
            s.speed = random_get_within_range(0.8, 1.0);
            s.color = make_vector4(1.0, 0.0, 0.0, 1.0);
            array_add(*stars, s);
    }

    Simp.set_render_target(window);
    
    quit := false;
    while !quit {
        Input.update_window_events();

        for Input.get_window_resizes() {
            Simp.update_window(it.window);  // Simp will do nothing if it doesn't care about this window.
            
            if it.window == window {
                should_reinit := (it.width != window_width) || (it.height != window_height);

                window_width  = it.width;
                window_height = it.height;
			}            
		}

        for Input.events_this_frame {
            if it.type == .QUIT then quit = true;

            if it.type == {
              case .KEYBOARD;
                if it.key_pressed && it.key_code == .ESCAPE {
                    quit = true;
                }

                if it.key_pressed && it.key_code == #char " " {  // Press spacebar to take a screenshot.
                }
            }
        }

        for stars {
            it.quad.y -= it.speed;
            it.quad.w -= it.speed;
            if it.quad.y < 0 {
                it.quad.y = cast(float)window_height;
                it.quad.w = cast(float)window_height - 4;
            }
        }

        draw_one_frame();

        //sleep_milliseconds(10);
        reset_temporary_storage();
    }
}

draw_one_frame :: () {
    Simp.clear_render_target(.0, .0, .0, 1);
    Simp.set_shader_for_color();

    for stars {
        Simp.immediate_quad(it.quad.x, it.quad.y, it.quad.z, it.quad.w, it.color);
    }  

    //Simp.immediate_quad(250.0, 250.0, 20.0, 20.0, Vector4.{0.0, 1.0, 0.0, 1.0});
    //Simp.immediate_quad(10.0, 10.0, 20.0, 20.0, Vector4.{1.0, 0.0, 0.0, 1.0});
    Simp.swap_buffers(window);
}

working_directory_set := false;

Simp  :: #import "Simp";
Input :: #import "Input";
#import "Window_Creation";
#import "Basic";
#import "Math";
#import "System";  // For get_path_of_running_executable. @Cleanup.
#import "String";  // For path_strip_filename. @Cleanup.
#import "Random";

#run {
    #if OS == .WINDOWS {
        WR :: #import "Windows_Resources";
        WR.disable_runtime_console();
    }
}
