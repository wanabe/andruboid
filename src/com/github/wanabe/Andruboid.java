package com.github.wanabe;

import android.app.Activity;
import android.os.Bundle;

public class Andruboid extends Activity
{
    /** Called when the activity is first created. */
    @Override
    public void onCreate(Bundle savedInstanceState)
    {
        super.onCreate(savedInstanceState);
        run("title 'this ' + \"is #{:andruboid} workng #{'!' * 3}\"" );
    }

    static {
        System.loadLibrary("andruboid");
    }

    protected native void run(String s);

    protected void title(String s) {
        setTitle(s);
    }
}
