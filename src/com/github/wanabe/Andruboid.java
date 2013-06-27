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
        String ret = initialize(updateScript());
		if (ret.length() > 0) {
			setTitle(ret);
		}
    }

	String[] updateScript() {
		String [] files = {"jmi.rb", "android.rb", "main.rb"};
		try {
			for(int i = 0;i < files.length; i++) {
				InputStream src = getAssets().open(files[i]);
				files[i] = new Scanner(src, "UTF-8").useDelimiter("//A").next();
			}
		} catch(IOException e) {
		}
		return files;
	}


    public native String initialize(String[] str);

    static {
        System.loadLibrary("andruboid");
    }
}
