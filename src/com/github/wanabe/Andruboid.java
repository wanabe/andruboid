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
import android.os.Process;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.DatePickerDialog;
import android.app.TimePickerDialog;
import android.view.View;
import android.widget.RadioGroup;
import android.widget.AdapterView;
import android.widget.AbsListView;
import android.widget.DatePicker;
import android.widget.TimePicker;
import android.content.DialogInterface;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Color;

public class Andruboid extends Activity{
	int mrb;
	String at;

	protected void showError(Throwable e) {
		AlertDialog.Builder builder = new AlertDialog.Builder(this);
		builder.setTitle(e.getClass().getSimpleName() + " at " + at).setMessage(e.getMessage());
		builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				close(mrb);
				finish();
			}
		});
		builder.show();
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
			if (at.contains(".rb") && at.charAt(0) != '#') {
				evalScript(mrb, at, loadAsset(dir, at));
			}
		}
	}

	void handleEvent(int type, int id, int opt) {
		try {
			handle(mrb, type, id, opt);
		} catch(Throwable e) {
			at = "handle " + Integer.toString(type);
			showError(e);
		}
	}

	void handleEvent(int type, int id, int[] opt) {
		try {
			handle(mrb, type, id, opt);
		} catch(Throwable e) {
			at = "handle " + Integer.toString(type);
			showError(e);
		}
	}

	void handleEvent(int type, int id, Object opt, Class opt2) {
		try {
			handle(mrb, type, id, opt, opt2);
		} catch(Throwable e) {
			at = "handle " + Integer.toString(type);
			showError(e);
		}
	}

	public native int initialize();
	public native void evalScript(int mrb, String name, String scr);
	public native void run(int mrb);
	public native void handle(int mrb, int type, int id, int opt);
	public native void handle(int mrb, int type, int id, int[] opt);
	public native void handle(int mrb, int type, int id, Object opt, Class opt2);
	public native void close(int mrb);

	static {
		System.loadLibrary("andruboid");
	}

	static class Listener implements 
	  View.OnClickListener, 
	  RadioGroup.OnCheckedChangeListener,
	  AdapterView.OnItemClickListener,
	  AdapterView.OnItemSelectedListener,
	  AbsListView.OnScrollListener,
	  DialogInterface.OnClickListener,
	  DatePickerDialog.OnDateSetListener,
	  TimePickerDialog.OnTimeSetListener {
		private static final int
		  ON_CLICK = 0,
		  ON_CHECKED_CHANGE = 1,
		  ON_ITEM_CLICK = 2,
		  ON_ITEM_SELECTED = 3,
		  ON_NOTHING_SELECTED = 4,
		  ON_SCROLL = 5,
		  ON_SCROLL_STATE_CHANGED = 6,
		  ON_DATE_SET = 7,
		  ON_TIME_SET = 8,
		  ON_DRAW = 9;
		Andruboid self;
		int id;

		public Listener(Andruboid self, int id) {
			this.self = self;
			this.id = id;
		}

		@Override
		public void onClick(View v) {
			self.handleEvent(ON_CLICK, id, 0);
		}

		@Override
		public void onCheckedChanged(RadioGroup rg, int checkedId) {
			self.handleEvent(ON_CHECKED_CHANGE, id, 0);
		}
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position, long itemId) {
			self.handleEvent(ON_ITEM_CLICK, id, position);
		}
		@Override
		public void onItemSelected(AdapterView<?> parent, View view, int position, long itemId) {
			self.handleEvent(ON_ITEM_SELECTED, id, position);
		}
		@Override
		public void onNothingSelected(AdapterView<?> parent) {
			self.handleEvent(ON_NOTHING_SELECTED, id, 0);
		}
		@Override
		public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
			self.handleEvent(ON_SCROLL, id, firstVisibleItem);
		}
		@Override
		public void onScrollStateChanged(AbsListView view, int scrollState) {
			self.handleEvent(ON_SCROLL_STATE_CHANGED, id, scrollState);
		}
		@Override
		public void onClick(DialogInterface dialog, int which) {
			self.handleEvent(ON_CLICK, id, which);
		}
		@Override
		public void onDateSet(DatePicker view, int year, int monthOfYear, int dayOfMonth) {
			int[] ary = {year, monthOfYear, dayOfMonth};
			self.handleEvent(ON_DATE_SET, id, ary);
		}
		@Override
		public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
			int[] ary = {hourOfDay, minute};
			self.handleEvent(ON_TIME_SET, id, ary);
		}
		public void onDraw(Canvas canvas) {
			self.handleEvent(ON_DRAW, id, canvas, android.graphics.Canvas.class);
		}
	}

	static class CustomView extends View {
		public Listener listener;
		public Andruboid self;
		public CustomView(Andruboid self) {
			super(self);
			this.self = self;
			listener = null;
		}
		public void setOnDraw(Listener listener) {
			this.listener = listener;
		}
		@Override
		protected void onDraw(Canvas canvas) {
			if (listener != null) {
				listener.onDraw(canvas);
			}
		}
	}
}
