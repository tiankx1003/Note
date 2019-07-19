/**
 * TestGetClassLoader
 */
public class TestGetClassLoader {

    public static void main(String[] args) {
        System.out.println(TestGetClassLoader.class.getClassLoader());
        // sun.misc.Launcher$AppClassLoader@18b4aac2
        System.out.println(TestGetClassLoader.class.getClassLoader().getParent());
        // sun.misc.Launcher$ExtClassLoader@1edf1c96
        //null
        System.out.println(Object.class.getClassLoader());
        //java.lang.NullPointerException
        System.out.println(Object.class.getClassLoader().getParent());
    }
}