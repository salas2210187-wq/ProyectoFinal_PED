# Este archivo funciona como lanzador del dashboard. Su único propósito es ejecutar Streamlit desde Python
import subprocess
import sys

def main():
    # Ruta del archivo Streamlit a ejecutar
    streamlit_file = "Main.py"

    # Comando: streamlit run
    subprocess.run([sys.executable, "-m", "streamlit", "run", streamlit_file])

# Este bloque garantiza que main() solo se ejecute si este archivo se corre directamente
if __name__ == '__main__':
    main()


