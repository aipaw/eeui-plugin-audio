package eeui.android.audio.service;

import android.annotation.SuppressLint;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Message;

import org.greenrobot.eventbus.EventBus;

import java.util.Timer;
import java.util.TimerTask;

import app.eeui.framework.ui.eeui;
import eeui.android.audio.event.AudioEvent;

@SuppressLint({"HandlerLeak", "StaticFieldLeak"})
public class MusicService {

    private Timer timer;
    private String url;
    private static MediaPlayer mPlayer = null;
    private static MusicService service;

    private class PlayAsyncTask extends AsyncTask<String, Integer, String> {
        @Override
        protected String doInBackground(String... strings) {
            setUrl(strings[0]);
            setListener();
            statTimer();
            mPlayer.start();
            EventBus.getDefault().post(new AudioEvent(url, AudioEvent.STATE_STARTPLAY));
            return null;
        }
    }

    public static MusicService getService() {
        if (service == null)
            service = new MusicService();
        return service;
    }

    public void release() {
        if (mPlayer != null) {
            try {
                mPlayer.stop();
                mPlayer.release();
            } finally {
                mPlayer = null;
            }
        }
    }

    public void setUrl(String url) {
        if (url == null || url.equals(this.url)) {
            return;
        }
        this.url = url;
        try {
            if (mPlayer != null) {
                release();
            }
            mPlayer = new MediaPlayer();
            if (url.startsWith("file://assets/")) {
                AssetFileDescriptor assetFile = eeui.getApplication().getAssets().openFd(url.substring(14));
                mPlayer.setDataSource(assetFile.getFileDescriptor(), assetFile.getStartOffset(), assetFile.getLength());
            }else{
                mPlayer.setDataSource(url);
            }
            mPlayer.prepare();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void play(String url) {
        new PlayAsyncTask().execute(url);
    }

    public void pause() {
        if (mPlayer != null) {
            mPlayer.pause();
        }
    }

    public void stop() {
        if (mPlayer != null) {
            mPlayer.stop();
            mPlayer.release();
            mPlayer = null;
            this.url = null;
        }
    }

    public void seek(int msec) {
        if (mPlayer != null) {
            mPlayer.seekTo(msec);
        }
    }

    public boolean isPlay() {
        if (mPlayer != null) {
            mPlayer.isPlaying();
        }
        return false;
    }

    public void volume(int vo) {
        if (mPlayer != null) {
            mPlayer.setVolume(vo, vo);
        }
    }

    public void setLoop(boolean loop) {
        if (mPlayer != null) {
            mPlayer.setLooping(loop);
        }
    }

    public void setListener() {
        if (mPlayer != null) {
            mPlayer.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                @Override
                public void onPrepared(MediaPlayer mediaPlayer) {
                    EventBus.getDefault().post(new AudioEvent(url, AudioEvent.STATE_PREPARED));
                }
            });
            mPlayer.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
                @Override
                public void onCompletion(MediaPlayer mediaPlayer) {
                    EventBus.getDefault().post(new AudioEvent(url, AudioEvent.STATE_COMPELETE));
                    cancelTimer();
                }
            });
            mPlayer.setOnErrorListener(new MediaPlayer.OnErrorListener() {
                @Override
                public boolean onError(MediaPlayer mediaPlayer, int i, int i1) {
                    EventBus.getDefault().post(new AudioEvent(url, AudioEvent.STATE_ERROR));
                    cancelTimer();
                    return false;
                }
            });
            mPlayer.setOnSeekCompleteListener(new MediaPlayer.OnSeekCompleteListener() {
                @Override
                public void onSeekComplete(MediaPlayer mediaPlayer) {
                    EventBus.getDefault().post(new AudioEvent(url, AudioEvent.STATE_SEEK_COMPELETE));
                }
            });
            mPlayer.setOnBufferingUpdateListener(new MediaPlayer.OnBufferingUpdateListener() {
                @Override
                public void onBufferingUpdate(MediaPlayer mediaPlayer, int i) {
                    EventBus.getDefault().post(new AudioEvent(url, AudioEvent.STATE_BufferingUpdate));
                }
            });
        }
    }

    Handler handler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == 1 && mPlayer != null) {
                EventBus.getDefault().post(new AudioEvent(url, mPlayer.getCurrentPosition(), mPlayer.getDuration(), AudioEvent.STATE_PLAY));
            }
            super.handleMessage(msg);
        }
    };

    public void cancelTimer() {
        if (timer != null)
            timer.cancel();
    }

    public void statTimer() {
        if (timer != null) {
            timer.cancel();
        }
        timer = new Timer();
        TimerTask timerTask = new TimerTask() {
            @Override
            public void run() {
                Message message = new Message();
                message.what = 1;
                handler.sendMessage(message);
            }
        };
        timer.schedule(timerTask, 0, 500);
    }
}
