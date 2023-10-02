document.addEventListener("DOMContentLoaded", function () {
  const cells = document.querySelectorAll(".cell");
  const playButton = document.getElementById("play");
  const endButton = document.getElementById("end");

  let simulationState = playButton.getAttribute("data-simulation-state");
  let timer;

  // Event listener per il pulstante "Play / Pause"
  playButton.addEventListener("click", function () {
    if (simulationState === "stopped") {
      startSimulation();
      simulationState = "running";
      playButton.setAttribute("data-simulation-state", simulationState);
      playButton.innerText = "Pause";
    } else {
      stopSimulation();
      simulationState = "stopped";
      playButton.setAttribute("data-simulation-state", simulationState);
      playButton.innerText = "Play";
    }
  });

  // Event listener per il pulsante "End"
  endButton.addEventListener("click", function () {
    if (simulationState === "running") {
      endSimulation();
      simulationState = "stopped";
      playButton.innerText = "Play";
    }
  });

  cells.forEach((cell) => {
    cell.addEventListener("click", function () {
      // Togli o aggiungi la classe "alive" alla cella per selezionarla o deselezionarla
      this.classList.toggle("alive");
    });
  });

  // Funzione per terminare la simulazione
  function endSimulation() {
    function nextStep() {
      const initialState = getGridState();
      const nextState = calculateNextState(initialState);

      // Se lo stato successivo è diverso da quello corrente, continua la simulazione
      if (!isSameState(nextState, initialState)) {
        setGridState(nextState);
        // Aggiunge un ritardo di 1 millisecondo
        setTimeout(nextStep, 1);
      } else {
        // Lo stato successivo è uguale a quello corrente, quindi la simulazione è terminata
        simulationState = "stopped";
        playButton.innerText = "Play";

        // Nascondi il button "Play / Pause" aggiungendo la classe "hidden"
        playButton.classList.add("hidden");
      }
    }

    nextStep();
  }

  // Funzione per avviare la simulazione automatica
  function startSimulation() {
    timer = setInterval(function () {
      // Crea una nuova griglia di 13x13 inizializzata con nessuna cella viva
      const newGrid = Array.from({ length: 13 }, () => Array(13).fill(false));

      // Itera attravero le righe e colonne della griglia
      for (let row = 0; row < 13; row++) {
        for (let col = 0; col < 13; col++) {
          // Ottiene la cella corrente della lista delle celle
          const cell = cells[row * 13 + col];
          // Calcola il numero di celle adiacenti vive
          const neighbors = countAliveNeighbors(row, col);

          if (cell.classList.contains("alive")) {
            // Se la cella è viva, verifica se il numero di vicini è inferiore a 2 o superiore a 3
            if (neighbors < 2 || neighbors > 3) {
              // Se il numero di vicini non è nel range corretto, imposta la nuova griglia per indicare che la cella muore
              newGrid[row][col] = false;
            } else {
              newGrid[row][col] = true;
            }
          } else {
            // Se la cella è morta, verifica se ha esattamente 3 vicini vivi
            if (neighbors === 3) {
              // Se ha 3 vicini vivi, imposta la nuova griglia per indicare che la cella nasce (diventa viva)
              newGrid[row][col] = true;
            }
          }
        }
      }

      // Aggiorna lo stato delle celle sulla base della griglia
      cells.forEach((cell, index) => {
        if (newGrid[Math.floor(index / 13)][index % 13]) {
          cell.classList.add("alive");
        } else {
          cell.classList.remove("alive");
        }
      });
      playButton.setAttribute("data-simulation-state", simulationState);
      // Esegue la simulazione ogni secondo
    }, 1000);
  }

  // Funzione per interrompere la simulazione automatica
  function stopSimulation() {
    clearInterval(timer);

    if (simulationState === "running") {
      // Invia un'azione al server tramite ActionCable per interrompere la simulazione
      App.gameChannel.perform("stop_simulation");
    }
  }

  // Funzione per avanzare di un passo nella simulazione
  function advanceGameStep() {
    const initialState = getGridState();
    let nextState = initialState;

    while (true) {
      nextState = calculateNextState(nextState);

      // Se lo stato non cambia, si è in uno stato stabile o terminale
      if (isSameState(nextState, initialState)) {
        break;
      }
    }

    // Ora `nextState` è l'ultimo stato possibile
    setGridState(nextState);
    simulationState = "stopped";
    playButton.innerText = "Play";
  }

  // Funzione per ottenere lo stato corrente della griglia
  function getGridState() {
    const state = [];
    cells.forEach((cell) => {
      state.push(cell.classList.contains("alive"));
    });
    return state;
  }

  // Funzione per calcolare il prossimo stato della griglia
  function calculateNextState(currentState) {
    const newGrid = Array.from({ length: 13 }, () => Array(13).fill(false));

    for (let row = 0; row < 13; row++) {
      for (let col = 0; col < 13; col++) {
        // Calcola il numero di vicini vivi della cella corrente utilizzando la funzione countAliveNeighbors
        const neighbors = countAliveNeighbors(row, col, currentState);

        // Verifica se la cella corrente è attualmente contrassegnata come "viva" (true) nello stato corrente
        if (currentState[row * 13 + col]) {
          if (neighbors < 2 || neighbors > 3) {
            newGrid[row][col] = false;
          } else {
            newGrid[row][col] = true;
          }
        } else {
          if (neighbors === 3) {
            newGrid[row][col] = true;
          }
        }
      }
    }

    // Restituisce la nuova griglia
    return newGrid.flat();
  }

  // Funzione per verificare se due stati della griglia sono uguali
  function isSameState(state1, state2) {
    for (let i = 0; i < state1.length; i++) {
      if (state1[i] !== state2[i]) {
        return false;
      }
    }
    return true;
  }

  // Funzione per impostare lo stato della griglia
  function setGridState(state) {
    cells.forEach((cell, index) => {
      if (state[index]) {
        cell.classList.add("alive");
      } else {
        cell.classList.remove("alive");
      }
    });
  }


  // Funzione per contare il numero di celle adiacenti vive
  function countAliveNeighbors(row, col) {
    let aliveNeighbors = 0;

    // Definisce le posizioni relative delle celle adiacenti
    const positions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1], [1, 0], [1, 1]
    ];

    // Itera attraverso le posizioni relative delle celle adiacenti
    for (const [rowOffset, colOffset] of positions) {
      // Calcola la riga e la colonna della cella adiacente
      const newRow = row + rowOffset;
      const newCol = col + colOffset;

      // Verifica se la cella adiacente è all'interno della griglia
      if (newRow >= 0 && newRow < 13 && newCol >= 0 && newCol < 13) {
        // Ottiene il riferimento alla cella adiacente nell'array di celle
        const cell = cells[newRow * 13 + newCol];

        if (cell && cell.classList.contains("alive")) {
          // Incrementa il conteggio dei vicini vivi
          aliveNeighbors++;
        }
      }
    }

    return aliveNeighbors;
  }
});

// Funzione di inizializzazione del gioco
function initializeGame() {
}

export { initializeGame };
