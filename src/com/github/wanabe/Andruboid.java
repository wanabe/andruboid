package com.github.wanabe;

import java.io.File;
import java.io.InputStream;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.BufferedWriter;
import java.io.IOException;
import java.util.Scanner;
import android.os.Bundle;
import android.os.Environment;
import android.app.Activity;
import android.app.AlertDialog;
import android.view.View;

public class Andruboid extends Activity{
	int mrb;
	String at;

	protected void showError(Throwable e) {
		String msg = e.getMessage();
		if (msg.equals("SystemExit: SystemExit")) {
			finish();
		} else {
			new AlertDialog.Builder(this).setTitle(e.getClass().getSimpleName() + " at " + at)
				.setMessage(msg).show();
		}
	}

	@Override
	public void onCreate(Bundle state) {
		super.onCreate(state);
		try {
			at = "initialze";
			mrb = initialize();
			loadScripts("andruboid");
			at = "run";
			run(mrb);
		} catch(Throwable e) {
			showError(e);
		}
	}

	Scanner loadAsset(File dir, String name, String pattern) throws IOException {
		InputStream src;
		if (dir == null) {
			src = getAssets().open(name);
		} else {
			File file = new File(dir, name);
			if (!file.exists()) {
				BufferedWriter out = new BufferedWriter(new FileWriter(file));
				out.write(loadAsset(null, name));
				out.close();
			}
			src = new FileInputStream(file);
		}
		return new Scanner(src, "UTF-8").useDelimiter(pattern);
	}

	String loadAsset(File dir, String name) throws IOException {
		return loadAsset(dir, name, "\\A").next();
	}

	void loadScripts(String dirName) throws IOException {
		File dir = new File(Environment.getExternalStorageDirectory(), dirName);
		if (!dir.exists()) {
			dir.mkdir();
		}

		Scanner recipe = loadAsset(dir, "recipe", "\n");
		while(recipe.hasNext()) {
			at = recipe.next();
			if (at.contains(".rb")) {
				evalScript(mrb, loadAsset(dir, at));
			}
		}
	}

	void handleClick(int id) {
		try {
			click(mrb, id);
		} catch(Throwable e) {
			at = "OnClick";
			showError(e);
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
