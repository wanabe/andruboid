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
import java.lang.String;
import java.util.Scanner;

public class Andruboid extends Activity
{
    @Override
    public void onCreate(Bundle state) {
        super.onCreate(state);
        initialize(updateScript());
    }

	String updateScript() {
		File script = new File("/sdcard/andruboid/main.rb");
		try {
			byte[] buf = new byte[4096];
			int len;
			InputStream src = getAssets().open("main.rb");
			FileOutputStream dst = new FileOutputStream(script);
			while ((len = src.read(buf)) != -1) {
				dst.write(buf, 0, len);
			}
			dst.close();
			src.close();

			src = getAssets().open("lib.rb");
			return new Scanner(src, "UTF-8").useDelimiter("//A").next();
		} catch(IOException e) {
		}
		return null;
	}


    public native void initialize(String str);

    static {
        System.loadLibrary("andruboid");
    }
}
