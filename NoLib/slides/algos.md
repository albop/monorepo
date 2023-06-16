# Algorithms and model definitions

---

# Linear Time iteration

- $s_t \in R^{n_s} $: continuous states 
- $x_t \in R^{n_x}$: continuous controls 
- $\epsilon_t \in R^{n_e}$: exogenous shock 
- State transition
$$s_{t+1} = g(s_{t}, x_{t}, \epsilon_t)$$
- Euler equation (aka arbitrage)
$$E_t [ f(s_t, x_t, s_{t+1}, x_{t+1}) ] = 0$$

---

# Markov Decision Process with Continous Controls

----

## General information

- controlled markov process:
    - state: $s_t \in \mathcal{S}$
    - action/control: $x_t \in \mathcal{X}(s_t)$
- transition probabilities: $s_{t+1}$ follows a distribution $\tau(s_t, x_t)$ is a distribution in $\mathcal{S}$
        
- optimality conditions:
    - $E_t[ f(s_t, x_t, s_{t+1}, x_{t+1})] = 0$
- remark: for reinforcement learning / vfi we need:
    - rewards/utility: $r(s_t, x_t$)

----

## Some additional restrictions

- Structure of states: $\mathcal{S} =\mathcal{D} \times \mathcal{C}$
- $|\mathcal{D}|<\infty$: *discrete* states
    - follow a fixed discrete markov chain specified by transition matrix $P$
- $\mathcal{C} \subset R^{n_{sc}}$: *continuous* states
    - evolve according to a transition function
    $s^c_{t+1} = g(s^d_t, s^c_t, x_t, s^d_{t+1})$

----

## Model discretization

The decision rule is $x_t = \varphi(s^d_t, s^c_t)$

[illustration]

Since first argument is discrete we can define several functions $(\varphi^i(s^c))_i$

Each function $\varphi^i$ is still defined by an infinite number of parameters.

- characterize the values at a finite number of points...
- ...and use interpolation to find the values between the grid points

----

## Setting up the state-space

- define a discrete subset $\mathcal{C^d}$ of $\mathcal{C}$, the *grid*
    - cf CGrid, SGrid, $\times$
- represent vectors of control values on the grid
    - GArray
- get grid values
    - linear / multidimensional: GArray[]
- interpolate values between the grid points
    - GArray()
How do you represent a point on the grid? Between the gridpoints?

----

## Model transition

- What about: $\tau(s_t, x_t)$ ?
- Take $s_t$ on the grid: $s_t=(s^d_{[k]}, s^c_{[l]})$:
    - next discrete state $s^d$: with probability $P_{k k'}$:
    $$P(s^d_{[l]})$$
    - next continous state $s^c$: with probability $P_{k k'}$:
        $$g(s^d_{[k]}, s^c_{[l]}, x_{[kl]}, s^d_{[k k']})$$
- We can represent  $\tau(s_t, x_t)$  by an iterator yielding $(w, (s^d, s^c))$

----

##  Measuring optimality

$$E_t[ f(s_t, x_t, s_{t+1}, x_{t+1})] = 0$$
$$E_{s'|s}[ f(s, \varphi(s), s',\varphi(s')] = 0$$

Or: (full version)

$$F(s, x, \varphi) = E_{s' \in \tau(s,x)}[ f(s, x, s',\varphi(s')] = 0$$

Note  when policy is approximated by gridpoint values $\varphi(s)=\mathcal{I}(s; \overrightarrow{x})$ so we can define $F(s,x,\overrightarrow{x}) \in R^{n_x}$
If we take all grid points $s$  we can define:

$$F(\overrightarrow{x_t}, \overrightarrow{x_{t+1}}) \in \left(R^{n_x}\right)^{|\mathcal{G}| } = (F(s, \overrightarrow{x_t}_{[s]}, \overrightarrow{x_{t+1}}))_{s\in \mathcal{G}} $$

----

##  Measuring optimality (complementarities)

- In some cases the optimality condition is met only if a given constraint is not met.
- In that case we can rewrite the optimality condition as:

$$E_t[ f(s_t, x_t, s_{t+1}, x_{t+1})] \geq 0 \perp b(x_t)\geq 0$$

where $b(x_t)$ is the constraint.
- By convention $a\perp b$ exactly means $a\geq0$,$b\geq0$ and $a b = 0$


- It often arises from constrained optimization
- In practice, one can either:
    - resort to a solver which can deal with complementarities (like `NLsolve`)
    - replace $a\geq 0 \perp b \geq$ by the equivalent expression $min(a,b)$ or the Fisher Burmeister function: $\sqrt(a^2+b^2) - (a+b)$ which has the same zeros (and is differentiable)



----

## Time iteration

Recall our optimality criterium:
$$F(\overrightarrow{x_t}, \overrightarrow{x_{t+1}})$$

The optimal policy $\overrightarrow{x}$ satisfies:

$$F(\overrightarrow{x}, \overrightarrow{x})=0$$

Time iteration operator $T(\overrightarrow{x})$ is defined implicitly by:
 $$F(T(\overrightarrow{x}), \overrightarrow{x})=0$$
- it can be computed by finding the zero of  $\overrightarrow{u}->F( \overrightarrow{u}, \overrightarrow{x})$

- *Time iteration algorithm*: 
    - iterate on $\overrightarrow{x_{n+1}} = T(\overrightarrow{x_n})$ 
    - until $|x_n-x_{n+1}|<\eta$ or $|F(x_{n+1}, x_n)|<\epsilon$
    - advice: check that $\lambda_n = \frac{|x_n-x_{n+1}|}{|x_{t-1}-x_{n}|}$

----

## (Improved) Time iteration


The recursive sequence $\overrightarrow{x_{n+1}} = T(\overrightarrow{x_n})$ converge at a geometric rate. Can we speed it up?

Suppose we know how to compute $T^{\prime}$. Can we do a smart gradient descent from there?

We look for a fixed point $$\overrightarrow{x}= T(\overrightarrow{x})$$

We can do the Taylor expansion
$ \overrightarrow{x} = T(x_n) + T^{\prime}(\overrightarrow{x_n})\left(\overrightarrow{x}  - \overrightarrow{x_{n+1}} \right)$

Taking the difference: 
$ \overrightarrow{x_{n+1}} - \overrightarrow{x} =  T^{\prime}(\overrightarrow{x_n})\left( \overrightarrow{x_{n}}- \overrightarrow{x}  \right)$

A good guess for the steady-state:
$$\overrightarrow{x}  = (I-T^{\prime})^{-1} \left(\overrightarrow{x_{n+1}} - T^{\prime}(\overrightarrow{x_{n}})\right)$$

----


##  Solving for optimal choices

$$E_t[ f(s_t, x_t, s_{t+1}, x_{t+1})] = 0$$
$$E_{s'|s}[ f(s, \varphi(s), s',\varphi(s')] = 0$$

Or: (full version)

$$F(s, x, \varphi) =


E_{s' \in \tau(s,x)}[ f(s, x, s',\varphi(s')] = 0$$

Note  when policy is approximated by gridpoint values $\varphi(s)=\mathcal{I}(s; \overrightarrow{x})$ so we can define $F(s,x,\overrightarrow{x}) \in R^{n_x}$
If we take all grid points $s$  we can define:

$$F(\overrightarrow{x_t}, \overrightarrow{x_{t+1}}) = (F(s, \overrightarrow{x_t}_{[s]}, \overrightarrow{x_{t+1}}))_{s\in \mathcal{G}} \in \left(R^{n_x}\right)^{|\mathcal{G}| }$$


---

# Heterogenous agents

- variables
    - predetermined:
        - $z_t$: aggregate shock
        - $\overrightarrow{\mu}_t$: distribution of agents
    - jump variables: (aka controls)
        - $\overrightarrow{x}_t$: individual decision rule 
        - $y_t$: aggregate variables
        - $p_t$: projection variables
- equations:
    - aggregate shock law of motion:
        - shock law of mothion:
        $$z_t = G^e(z_{t-1})$$
        - distribution transition
        $$\mu_{t+1} = G(\mu_t,x_t,p_t, p_{t+1})$$
    - agents optimality
    $$F(x_t, x_{t+1}, p_t, p_{t+1}) = 0$$
    - aggregate optimality
    $$\mathcal{A}(x_t, \mu_t, y_t)= \int_s A(s, x_t(s), y_t) d\mu_t (s) = 0$$
    - projection
    $$p_t = P(y_t)$$