package com.github.wanabe;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.TextView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.app.AlertDialog;
import android.content.DialogInterface;

public class Andruboid extends Activity
{
    TextView screen;
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        setContentView(layout);

        Button btn = new Button(this);
        btn.setText("start bench");
        layout.addView(btn);

        ScrollView scroll = new ScrollView(this);
        layout.addView(scroll);

        LinearLayout layout2 = new LinearLayout(this);
        layout2.setOrientation(LinearLayout.VERTICAL);
        scroll.addView(layout2);

        ClickListener listener = new ClickListener();
        btn.setOnClickListener(listener);

        screen = new TextView(this);
        layout2.addView(screen);
    }

    static {
        System.loadLibrary("andruboid");
    }

    protected native void run();

    protected void print(String message) {
      screen.append(message);
    }
    protected void alert(String message) {
        new AlertDialog.Builder(this)
        .setTitle("alert")
        .setMessage(message)
        .setPositiveButton(
          "Ok",
          new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
            }
          })
        .show();
    }

    class ClickListener implements OnClickListener {
        @Override
        public void onClick(View v) {
            long t1 = System.currentTimeMillis();
            run();
            long t2 = System.currentTimeMillis();
            Button b = (Button)v;
            b.setText("ok: "  + ((t2 - t1) / 1000.0) + "sec.");
        }
    };
}
