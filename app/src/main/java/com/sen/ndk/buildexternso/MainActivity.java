package com.sen.ndk.buildexternso;

import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    TextView tv_content;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        tv_content=findViewById(R.id.tv_content);
        tv_content.setText("result is : "+MathTest.add(1,1));
    }
}
