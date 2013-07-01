package com.github.wanabe;

import android.app.Activity;
import android.widget.TextView;
import android.os.Bundle;
import java.io.IOException;
import java.io.InputStream;
import java.io.FileOutputStream;
import java.io.File;
import android.content.pm.PackageManager;
import android.content.pm.ApplicationInfo;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;
import java.util.Enumeration;
import java.util.Scanner;
import android.app.AlertDialog;

public class Andruboid extends Activity{
	int mrb;
	String at;

	@Override
	public void onCreate(Bundle state) {
		super.onCreate(state);
		try {
			at = "initialze";
			mrb = initialize();
			loadScripts();
			at = "run";
			run(mrb);
		} catch(RuntimeException e) {
			new AlertDialog.Builder(this).setTitle("Error at " + at)
			.setMessage(e.getMessage()).show();
		}
	}

	void loadScripts() {
		String [] files = {"jmi.rb", "android.rb", "main.rb"};
		try {
			for(int i = 0;i < files.length; i++) {
				at = files[i];
				InputStream src = getAssets().open(files[i]);
				evalScript(mrb, new Scanner(src, "UTF-8").useDelimiter("//A").next());
			}
		} catch(IOException e) {
		}
	}


	public native int initialize();
	public native void evalScript(int mrb, String scr);
	public native void run(int mrb);
	
	static {
		System.loadLibrary("andruboid");
	}
}
