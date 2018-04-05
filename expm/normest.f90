!Implements a user-friendly interface to the Higham norm estimator
module estnorm
  use dispmodule
  integer :: iseed(4)
contains 

  subroutine init_seed()
    iseed(1) = 3
    iseed(2) = 99
    iseed(3) = 199
    iseed(4) = 50
  end subroutine init_seed

  function normest(n,t0, matvec, matvec_transp) result(est)
    implicit none
    integer, intent(in) :: n,t0
    integer :: t 
    external matvec, matvec_transp
    double precision :: v(n), x(n,t0), xold(n,t0), wrk(t0), H(n)
    integer :: ind(n), indh(n), info
    double precision :: est
    integer :: kase,i,k !The reverse communication stuff
    i = 1 
    kase = 0
    t = min(n,t0)
    x(:,:) = 0d0
    
    do while ( (kase .ne. 0) .or. (i .eq. 1) ) 
       call dlacn1(n,t,v,x,n,xold,n,wrk,H,ind,indh, est, kase, iseed, info)
       !if ( (kase .eq. 0) .and. ((info .ne. 2) .and. (info .ne. 3))) then
       !   print *,'normest failed with info=',info
       !end if
       if ( kase .eq.  1 ) then
          do k = 1,t
             call matvec(x(:,k), xold(:,k))
          end do
          call dcopy(n*t, xold, 1, x, 1)
       else if ( kase .eq. 2 ) then
          do k = 1,t
             call matvec(x(:, k), xold(:, k))
          end do
          call dcopy(n*t, xold, 1, x, 1)
       else if ( kase .ne. 0 ) then
          print *,'norm est failed with kase=',kase 
       end if
       i = i + 1
    end do
  end function normest

  function znormest(n,t0, matvec, matvec_transp) result(est)
    implicit none
    integer, intent(in) :: n, t0
    integer :: t 
    external matvec, matvec_transp
    complex(8) :: v(n), x(n, t0), xold(n, t0)
    complex(8) ::  ZERO, ONE
    parameter( ZERO=(0.0d0,0.0d0), ONE=(1.0d0,0.0d0) )
    
    
    integer :: ind(n), indh(n), info
    double precision :: H(n)
    double precision :: est
    integer :: kase,i,k !The reverse communication stuff
    i = 1 
    kase = 0
    t = min(n,t0)

    x(:,:) = ZERO
    xold(:,:) = ZERO
    do while ( (kase .ne. 0) .or. (i .eq. 1) ) 
        call zlacn1(n, t, v, x, n, xold, n, H, ind, indh, est, kase, iseed, info)
        ! if ( (kase .eq. 0) .and. ((info .ne. 2) .and. (info .ne. 3))) then
        !    print *,'normest failed with info=',info
        ! end if
        if ( kase .eq.  1 ) then
           do k = 1,t
              ! print *,'matvec k=',k 
              call matvec(x(:, k), xold(:, k))
           end do
           call zcopy(n * t, xold, 1, x, 1)
        else if ( kase .eq. 2 ) then
           do k = 1,t
              ! print *, 'matvec_t k =',k
              call matvec_transp(x(:,k), xold(:,k))
           end do
           call zcopy(n * t, xold, 1, x, 1)
        else if ( kase .ne. 0 ) then
            print *,'norm est failed with kase=',kase 
        end if
        i = i + 1
     end do
  end function znormest

  function norm_true(n, matvec, matvec_transp) result(est)
    implicit none
    integer, intent(in) :: n
    external matvec, matvec_transp
    double precision, external :: dlange
    double precision, allocatable :: A(:, :), X(:)
    double precision est, work(n+2)
    double precision ::  ZERO, ONE
    parameter( ZERO=(0.0d0), ONE=(1.0d0) )
    integer :: k

    allocate(A(n, n), X(n))

    A(:, :) = ZERO
    X(:) = ZERO
    do k=1,n
       X(k) = ONE
       call matvec(X, A(:, k))
       X(k) = ZERO
    end do

    est = dlange('1', n, n, A, n, work) 
    deallocate(A)
  end function norm_true

  function znorm_true(n, matvec, matvec_transp) result(est)
    implicit none
    integer, intent(in) :: n
    external matvec, matvec_transp
    double precision, external :: zlange
    complex(8), allocatable :: A(:, :), X(:)
    double precision est, work(n+2)
    complex(8) ::  ZERO, ONE
    parameter( ZERO=(0.0d0,0.0d0), ONE=(1.0d0,0.0d0) )
    integer :: k

    allocate(A(n, n), X(n))

    A(:, :) = ZERO
    X(:) = ZERO
    do k=1,n
       X(k) = ONE
       call matvec(X, A(:, k))
       X(k) = ZERO
    end do

    est = zlange('1', n, n, A, n, work) 
    deallocate(A)
  end function znorm_true
  
end module estnorm
