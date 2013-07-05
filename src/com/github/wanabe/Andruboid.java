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
import android.view.View;

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
		} catch(Throwable e) {
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

	void handleClick(int id) {
		try {
			click(mrb, id);
		} catch(Throwable e) {
			new AlertDialog.Builder(this).setTitle("Error at OnClick")
				.setMessage(e.getMessage()).show();
		}
	}

	public native int initialize();
	public native void evalScript(int mrb, String scr);
	public native void run(int mrb);
	public native void click(int mrb, int id);

	static {
		System.loadLibrary("andruboid");
	}
	
	static class ClickListener implements View.OnClickListener {
		Andruboid self;
		int id;

		public ClickListener(Andruboid self, int id) {
			this.self = self;
			this.id = id;
		}

		@Override
		public void onClick(View v) {
			self.handleClick(id);
		}
	}
}
